"""The registry contract, the add_feature mechanics, and real copier runs."""

from pathlib import Path

import pytest

import bestie_template
from bestie_template import BestieError, add_feature, list_features


class TestRegistry:
    def test_bundled_registry_is_the_repo_one(self, repo_root):
        assert bestie_template.registry_path() == repo_root / "features.toml"

    def test_feature_names(self, registry):
        """Drift guard: the Python and Julia sides must see the same feature set."""
        assert sorted(registry) == [
            "agents",
            "changelog",
            "dependabot",
            "lint_action",
            "lint_action_explicit",
            "pre_commit",
            "pre_commit_with_config",
            "pre_commit_without_config",
            "testitem_cli",
        ]

    def test_every_entry_has_the_expected_keys(self, registry):
        for name, spec in registry.items():
            if "alias_of" in spec:
                assert set(spec) == {"alias_of"}, name
                continue
            assert set(spec) == {
                "description",
                "forced_data",
                "included_files",
                "required_fields",
                "requires_answers",
            }, name
            assert spec["description"] and spec["included_files"]

    def test_aliases_resolve(self, registry):
        resolved = bestie_template._resolve(registry, "pre_commit")
        assert resolved is registry["pre_commit_with_config"]

    def test_unknown_feature_lists_the_supported_ones(self, registry):
        with pytest.raises(BestieError, match=r"Unknown feature 'nope'.*agents"):
            bestie_template._resolve(registry, "nope")

    def test_unsupported_schema_version(self, tmp_path):
        path = tmp_path / "features.toml"
        path.write_text("schema_version = 99\n[features.x]\n")
        with pytest.raises(BestieError, match="schema_version"):
            bestie_template.load_registry(path)

    def test_list_features_is_sorted_and_json_ready(self, registry):
        features = list_features(registry)
        assert [feature["name"] for feature in features] == sorted(registry)
        assert {"name": "pre_commit", "alias_of": "pre_commit_with_config"} in features


def test_license_matches_the_repo(repo_root):
    """python/LICENSE must stay a verbatim copy: PEP 639 forbids ../ in license-files."""
    assert (repo_root / "python" / "LICENSE").read_bytes() == (repo_root / "LICENSE").read_bytes()


class TestAddFeature:
    """Mechanics, with the copier call stubbed out (see the copier_calls fixture)."""

    def test_excludes_everything_but_the_feature_files(self, tmp_path, registry, copier_calls):
        add_feature(["pre_commit"], tmp_path, registry=registry)
        (call,) = copier_calls
        assert call["exclude"][0] == "**"
        assert set(call["exclude"][1:]) == {
            f"!{file}" for file in registry["pre_commit_with_config"]["included_files"]
        }

    def test_data_merge_order_and_placeholders(self, tmp_path, registry, copier_calls):
        (tmp_path / ".copier-answers.yml").write_text(
            "PackageName: FromAnswers\nPackageOwner: owner\n_commit: v0.0.0\n"
        )
        add_feature(
            ["agents"], tmp_path, {"PackageName": "FromData"}, registry=registry, ref="HEAD"
        )
        (call,) = copier_calls
        assert call["data"]["PackageName"] == "FromData"  # data beats the answers file
        assert call["data"]["PackageOwner"] == "owner"  # answers survive
        assert call["data"]["AddAgentsMd"] is True  # forced_data is applied
        assert call["data"]["Authors"] == "UNUSED"  # unresolved placeholder field
        assert call["vcs_ref"] == "HEAD"
        assert "!.copier-answers.yml" in call["exclude"]  # updated, since it exists

    def test_answers_file_is_never_created(self, tmp_path, registry, copier_calls):
        result = add_feature(["agents"], tmp_path, {"PackageName": "Pkg"}, registry=registry)
        assert "!.copier-answers.yml" not in copier_calls[0]["exclude"]
        assert result["answers_file_updated"] is False
        assert not (tmp_path / ".copier-answers.yml").exists()

    def test_one_run_per_feature_in_order(self, tmp_path, registry, copier_calls):
        result = add_feature(
            ["testitem_cli", "agents"], tmp_path, {"PackageName": "Pkg"}, registry=registry
        )
        assert [applied["name"] for applied in result["applied"]] == ["testitem_cli", "agents"]
        assert [call["exclude"][1] for call in copier_calls] == ["!test/runtests.jl", "!AGENTS.md"]

    def test_a_bad_name_stops_the_batch_before_any_run(self, tmp_path, registry, copier_calls):
        with pytest.raises(BestieError, match="Unknown feature"):
            add_feature(["agents", "nope"], tmp_path, {"PackageName": "Pkg"}, registry=registry)
        assert copier_calls == []

    def test_missing_required_field_names_it_and_how_to_pass_it(self, tmp_path, registry):
        with pytest.raises(BestieError, match=r"PackageName.*-d PackageName="):
            add_feature(["agents"], tmp_path, registry=registry)

    def test_feature_needing_an_answers_file(self, tmp_path, registry):
        with pytest.raises(BestieError, match=r"requires \.copier-answers\.yml"):
            add_feature(["lint_action"], tmp_path, registry=registry)

    def test_copier_failure_is_wrapped(self, tmp_path, registry, monkeypatch):
        def boom(**kwargs):
            raise RuntimeError("template exploded")

        monkeypatch.setattr("copier.run_copy", boom)
        with pytest.raises(BestieError, match="copier failed: template exploded"):
            add_feature(["agents"], tmp_path, {"PackageName": "Pkg"}, registry=registry)

    def test_cleanup_race_is_ignored_but_other_oserrors_are_not(self, tmp_path, registry):
        """Copier's own temp-clone rmtree failing (Errno 39) must not fail the run."""
        clone = tmp_path / "copier._vcs.clone.abc123"
        (clone / "leftover").mkdir(parents=True)
        race = OSError(39, "Directory not empty", str(clone))
        assert bestie_template._cleanup_race_dir(race) == str(clone)
        assert bestie_template._cleanup_race_dir(OSError(13, "denied", str(clone))) is None
        assert bestie_template._cleanup_race_dir(RuntimeError("nope")) is None


@pytest.mark.integration
class TestAgainstTheRealTemplate:
    """Real copier runs on this checkout, mirroring test/test-add-feature.jl.

    `ref="HEAD"` is the working tree, matching the Julia tests' `use_latest`.
    """

    @pytest.fixture
    def template(self, repo_root):
        return str(repo_root)

    def test_agents_on_an_empty_folder(self, tmp_path, template):
        result = add_feature(
            ["agents"], tmp_path, {"PackageName": "FakePkg"}, template=template, ref="HEAD"
        )
        content = (tmp_path / "AGENTS.md").read_text()
        assert "FakePkg" in content and "Pkg.test()" in content
        assert not (tmp_path / ".copier-answers.yml").exists()
        assert result["applied"] == [{"name": "agents", "files": ["AGENTS.md"]}]

    def test_only_the_features_files_are_written(self, tmp_path, template):
        add_feature(
            ["agents", "pre_commit"],
            tmp_path,
            {"PackageName": "FakePkg"},
            template=template,
            ref="HEAD",
        )
        assert (tmp_path / ".JuliaFormatter.toml").is_file()
        generated = {path.name for path in tmp_path.iterdir()}
        assert generated == {
            "AGENTS.md",
            ".pre-commit-config.yaml",
            ".JuliaFormatter.toml",
            ".editorconfig",
            ".yamlfmt.yml",
            ".yamllint.yml",
            ".markdownlint.json",
        }

    def test_explicit_data_wins_and_the_answers_file_is_updated(self, tmp_path, template):
        (tmp_path / ".copier-answers.yml").write_text("PackageName: FromAnswers\n")
        result = add_feature(
            ["dependabot"], tmp_path, {"PackageName": "ExplicitName"}, template=template, ref="HEAD"
        )
        content = (tmp_path / ".github" / "dependabot.yml").read_text()
        assert "ExplicitName" in content and "FromAnswers" not in content
        assert result["answers_file_updated"]
        assert "ExplicitName" in (tmp_path / ".copier-answers.yml").read_text()

    def test_a_ref_predating_the_feature_errors(self, tmp_path, template):
        # v0.18.6 has no AGENTS.md: the run writes nothing, which must surface
        # as an error rather than a silent success
        with pytest.raises(BestieError, match="produced none of its files"):
            add_feature(
                ["agents"], tmp_path, {"PackageName": "FakePkg"}, template=template, ref="v0.18.6"
            )
        assert not (tmp_path / "AGENTS.md").exists()

    def test_unrelated_files_are_preserved(self, tmp_path, template):
        """The core invariant (Julia: _test_does_not_affect_other_files)."""
        import copier

        copier.run_copy(
            template,
            str(tmp_path),
            data={
                "PackageName": "PreservePkg",
                "PackageUUID": "01234567-89ab-4def-0123-456789abcdef",
                "Authors": "Test <test@test.org>",
                "PackageOwner": "testowner",
                "License": "MIT",
                "StrategyLevel": 0,
                "StrategyConfirmIncluded": False,
                "StrategyReviewExcluded": False,
            },
            defaults=True,
            quiet=True,
            vcs_ref="HEAD",
        )
        snapshot = {
            path.relative_to(tmp_path): path.read_bytes()
            for path in tmp_path.rglob("*")
            if path.is_file() and ".git" not in path.parts
        }
        assert snapshot, "full generation produced no files?"

        add_feature(["agents"], tmp_path, template=template, ref="HEAD")

        touched = {Path("AGENTS.md"), Path(".copier-answers.yml")}
        for relative, before in snapshot.items():
            if relative in touched:
                continue
            assert (tmp_path / relative).read_bytes() == before, f"{relative} changed"
        after = {
            path.relative_to(tmp_path)
            for path in tmp_path.rglob("*")
            if path.is_file() and ".git" not in path.parts
        }
        assert after <= set(snapshot) | touched
