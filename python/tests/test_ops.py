"""Unit tests for the add_feature mechanics with a stubbed copier call."""

from pathlib import Path

import pytest

import copier_features.ops as ops
from copier_features.errors import (
    AnswersFileRequiredError,
    CopierRunError,
    MissingRequiredFieldsError,
)
from copier_features.ops import build_exclude


@pytest.fixture
def copier_calls(monkeypatch):
    """Stub _run_copy, capturing the kwargs of each call."""
    calls: list[dict] = []
    monkeypatch.setattr(ops, "_run_copy", lambda **kwargs: calls.append(kwargs))
    return calls


def _write_answers(dst: Path, lines: str = "PackageName: FromAnswers\n_commit: v0.0.0\n"):
    (dst / ".copier-answers.yml").write_text(lines)


class TestBuildExclude:
    def test_without_answers(self):
        assert build_exclude(("a.txt", "b/c.txt"), False) == ["**", "!a.txt", "!b/c.txt"]

    def test_with_answers(self):
        assert build_exclude(("a.txt",), True) == ["**", "!a.txt", "!.copier-answers.yml"]


class TestAddFeatureUnit:
    def test_forced_data_and_placeholders(self, registry, tmp_path, copier_calls):
        result = ops.add_feature(
            ["testitem_cli"],
            tmp_path,
            template="tpl",
            registry=registry,
            placeholder_fields=("PackageName", "PackageOwner", "Authors"),
        )
        (call,) = copier_calls
        assert call["data"]["TestingStrategy"] == "testitem_cli"
        assert call["data"]["PackageName"] == "UNUSED"
        assert call["exclude"] == ["**", "!test/runtests.jl"]
        assert call["overwrite"] and call["defaults"] and call["quiet"]
        assert result.applied[0].files == ("test/runtests.jl",)
        assert not result.answers_file_updated

    def test_merge_order_answers_then_data_then_forced(self, registry, tmp_path, copier_calls):
        _write_answers(tmp_path, "PackageName: FromAnswers\nAddDependabot: false\n_commit: x\n")
        ops.add_feature(
            ["dependabot"],
            tmp_path,
            template="tpl",
            registry=registry,
            data={"PackageName": "Explicit", "AddDependabot": False},
        )
        (call,) = copier_calls
        # explicit data beats answers; forced_data beats explicit data
        assert call["data"]["PackageName"] == "Explicit"
        assert call["data"]["AddDependabot"] is True
        # copier-internal keys from the answers file are not passed through
        assert "_commit" not in call["data"]
        # the answers file is included in the run so it gets updated
        assert "!.copier-answers.yml" in call["exclude"]

    def test_answers_file_used_when_present(self, registry, tmp_path, copier_calls):
        _write_answers(tmp_path)
        result = ops.add_feature(["dependabot"], tmp_path, template="tpl", registry=registry)
        (call,) = copier_calls
        assert call["data"]["PackageName"] == "FromAnswers"
        assert result.answers_file_updated

    def test_missing_required_fields(self, registry, tmp_path, copier_calls):
        with pytest.raises(MissingRequiredFieldsError, match="PackageOwner, PackageName"):
            ops.add_feature(["changelog"], tmp_path, template="tpl", registry=registry)
        assert copier_calls == []

    def test_requires_answers(self, registry, tmp_path, copier_calls):
        with pytest.raises(AnswersFileRequiredError, match="lint_action"):
            ops.add_feature(["lint_action"], tmp_path, template="tpl", registry=registry)
        assert copier_calls == []

    def test_multiple_features_in_order(self, registry, tmp_path, copier_calls):
        result = ops.add_feature(
            ["agents", "pre_commit"],
            tmp_path,
            template="tpl",
            registry=registry,
            data={"PackageName": "Pkg"},
        )
        assert [applied.resolved_name for applied in result.applied] == [
            "agents",
            "pre_commit_with_config",
        ]
        assert len(copier_calls) == 2
        assert copier_calls[1]["exclude"][:2] == ["**", "!.pre-commit-config.yaml"]

    def test_ref_is_forwarded(self, registry, tmp_path, copier_calls):
        ops.add_feature(
            ["testitem_cli"], tmp_path, template="tpl", registry=registry, ref="v0.99.0"
        )
        assert copier_calls[0]["vcs_ref"] == "v0.99.0"

    def test_copier_failure_is_wrapped(self, registry, tmp_path, monkeypatch):
        def boom(**kwargs):
            raise RuntimeError("copier exploded")

        monkeypatch.setattr(ops, "_run_copy", boom)
        with pytest.raises(CopierRunError, match=r"testitem_cli.*copier exploded"):
            ops.add_feature(["testitem_cli"], tmp_path, template="tpl", registry=registry)

    def test_unknown_feature_via_add_feature(self, registry, tmp_path, copier_calls):
        from copier_features.errors import UnknownFeatureError

        with pytest.raises(UnknownFeatureError, match="Supported features"):
            ops.add_feature(["nonexistent"], tmp_path, template="tpl", registry=registry)
        assert copier_calls == []

    def test_batch_is_validated_before_any_run(self, registry, tmp_path, copier_calls):
        # changelog (second position) is missing PackageOwner: nothing at all
        # must be applied, including the valid first feature
        with pytest.raises(MissingRequiredFieldsError, match="changelog"):
            ops.add_feature(
                ["testitem_cli", "changelog"],
                tmp_path,
                template="tpl",
                registry=registry,
                data={"PackageName": "Pkg"},
            )
        assert copier_calls == []

    def test_later_features_see_earlier_forced_answers(self, registry, tmp_path, monkeypatch):
        # Mimic real copier: each run rewrites the answers file from the data
        # it was given. A later feature in the batch must see the earlier
        # feature's forced answers, like sequential single-feature calls.
        calls = []

        def fake_run(**kwargs):
            calls.append(kwargs)
            lines = [f"{key}: {value}" for key, value in sorted(kwargs["data"].items())]
            (tmp_path / ".copier-answers.yml").write_text("\n".join(lines) + "\n")

        monkeypatch.setattr(ops, "_run_copy", fake_run)
        _write_answers(tmp_path, "PackageName: Pkg\n")
        ops.add_feature(["agents", "dependabot"], tmp_path, template="tpl", registry=registry)
        assert calls[1]["data"]["AddAgentsMd"] is True

    def test_lint_action_happy_path_with_answers(self, registry, tmp_path, copier_calls):
        _write_answers(tmp_path)
        result = ops.add_feature(["lint_action"], tmp_path, template="tpl", registry=registry)
        (call,) = copier_calls
        assert call["exclude"][:2] == ["**", "!.github/workflows/Lint.yml"]
        assert result.applied[0].files == (".github/workflows/Lint.yml",)


class TestCleanupRace:
    """The known copier flake: rmtree of its temp VCS clone fails with
    ENOTEMPTY after the copy already succeeded. _run_copy treats it as
    success (same workaround as Julia's Copier._ignore_cleanup_race)."""

    def test_clone_dir_is_identified(self, tmp_path):
        import errno

        exc = OSError(
            errno.ENOTEMPTY,
            "Directory not empty",
            str(tmp_path / "copier._vcs.clone.abc123" / ".git" / "objects"),
        )
        assert ops._copier_cleanup_race_dir(exc) == str(tmp_path / "copier._vcs.clone.abc123")

    def test_other_oserrors_are_not_matched(self):
        import errno

        assert ops._copier_cleanup_race_dir(OSError(errno.ENOENT, "No such file", "/x")) is None
        assert (
            ops._copier_cleanup_race_dir(OSError(errno.ENOTEMPTY, "Directory not empty", "/x"))
            is None
        )
