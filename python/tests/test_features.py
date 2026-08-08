"""The registry contract, the add_feature mechanics, and real copier runs."""

from pathlib import Path

import pytest

import bestie_template
from bestie_template import TEMPLATE_URL, BestieError, add_feature, list_features


class TestRegistry:
    def test_bundled_registry_is_the_repo_one(self, repo_root):
        assert bestie_template.registry_path() == repo_root / "features.toml"

    def test_feature_names(self, registry):
        """Drift guard: the Python and Julia sides must see the same feature set."""
        assert sorted(registry) == [
            "agents",
            "changelog",
            "dependabot",
            "formatter_linter_config",
            "lint_action",
            "lint_action_explicit",
            "pre_commit",
            "testitem_cli",
            "vscode_recommendations",
        ]

    def test_every_entry_has_the_expected_keys(self, registry):
        for name, spec in registry.items():
            if "alias_of" in spec:
                assert set(spec) == {"alias_of"}, name
                continue
            assert set(spec) <= {
                "description",
                "forced_data",
                "included_files",
                "optional_files",
                "required_fields",
                "requires_answers",
            }, name
            assert set(spec) >= {
                "description",
                "forced_data",
                "included_files",
                "required_fields",
                "requires_answers",
            }, name
            for field, files in spec.get("optional_files", {}).items():
                # Keyed on boolean fields only, and the caller must be able to set them
                assert field in spec["required_fields"] or field in spec["forced_data"], name
                assert files and all(isinstance(file, str) for file in files), name
            assert spec["description"] and spec["included_files"]

    def test_aliases_resolve(self):
        # No entry in the real registry is currently an alias (#625 removed the last
        # one); exercise the generic resolution mechanism with a synthetic registry.
        synthetic = {
            "my_alias": {"alias_of": "real_feature"},
            "real_feature": {
                "description": "d",
                "forced_data": {},
                "included_files": ["f"],
                "required_fields": [],
                "requires_answers": False,
            },
        }
        resolved = bestie_template._resolve(synthetic, "my_alias")
        assert resolved is synthetic["real_feature"]

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
            f"!{file}" for file in registry["pre_commit"]["included_files"]
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

    @pytest.fixture
    def rewrites_the_answers_file(self, tmp_path, monkeypatch):
        """Stub copier doing what it really does: rewrite the answers file wholesale.

        Returns the answers path, seeded with a project two versions behind.
        """
        answers = tmp_path / ".copier-answers.yml"
        answers.write_text("PackageName: Pkg\n_commit: v0.15.0\n_src_path: https://old\n")

        def rewrite(**kwargs):
            (tmp_path / "AGENTS.md").touch()  # the feature's file, which add_feature checks for
            answers.write_text(
                "AddAgentsMd: true\nPackageName: Pkg\n_commit: v0.19.0\n_src_path: https://new\n"
            )

        monkeypatch.setattr(bestie_template, "_run_copy", rewrite)
        return answers

    def test_the_recorded_template_version_is_kept(
        self, tmp_path, registry, rewrites_the_answers_file
    ):
        """A feature applies a subset of the template, so it must not claim a full update."""
        add_feature(["agents"], tmp_path, registry=registry)

        text = rewrites_the_answers_file.read_text()
        assert "_commit: v0.15.0" in text  # bookkeeping restored
        assert "_src_path: https://old" in text
        assert "AddAgentsMd: true" in text  # the new answer is still recorded

    def test_the_template_version_can_be_advanced_on_request(
        self, tmp_path, registry, rewrites_the_answers_file
    ):
        add_feature(["agents"], tmp_path, registry=registry, preserve_template_version=False)

        text = rewrites_the_answers_file.read_text()
        assert "_commit: v0.19.0" in text
        assert "_src_path: https://new" in text

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

    def test_optional_files_are_written_when_the_flag_is_on(self, tmp_path, template):
        add_feature(
            ["lint_action_explicit"],
            tmp_path,
            {"AddPrecommit": False, "AddLychee": True},
            template=template,
            ref="HEAD",
        )
        workflow = (tmp_path / ".github/workflows/Lint.yml").read_text()
        assert "link-checker" in workflow
        # The job runs lychee with --config '.lychee.toml', so the config must be there too
        assert (tmp_path / ".lychee.toml").is_file()
        assert not (tmp_path / ".pre-commit-config.yaml").exists()

    def test_optional_files_are_skipped_for_a_false_string_flag(self, tmp_path, template):
        # "false" arrives as a truthy string from -d; only copier coerces it, and only later
        add_feature(
            ["lint_action_explicit"],
            tmp_path,
            {"AddPrecommit": "true", "AddLychee": "false"},
            template=template,
            ref="HEAD",
        )
        assert not (tmp_path / ".lychee.toml").exists()
        assert (tmp_path / ".pre-commit-config.yaml").is_file()

    def test_an_existing_optional_file_is_never_overwritten(self, tmp_path, template):
        (tmp_path / ".lychee.toml").write_text("# tuned by hand\n")
        add_feature(
            ["lint_action_explicit"],
            tmp_path,
            {"AddPrecommit": False, "AddLychee": True},
            template=template,
            ref="HEAD",
        )
        assert (tmp_path / ".lychee.toml").read_text() == "# tuned by hand\n"

    def test_only_the_features_files_are_written(self, tmp_path, template):
        add_feature(
            ["agents", "pre_commit", "formatter_linter_config"],
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

    def test_the_recorded_template_version_survives_a_real_run(self, tmp_path, template):
        """#626, against real copier: adding one file must not claim a full reconciliation."""
        answers = tmp_path / ".copier-answers.yml"
        answers.write_text(
            f"PackageName: FakePkg\n_commit: v0.18.6\n_src_path: {TEMPLATE_URL}\n",
            encoding="utf-8",
        )
        add_feature(["agents"], tmp_path, template=template, ref="HEAD")

        text = answers.read_text(encoding="utf-8")
        assert (tmp_path / "AGENTS.md").is_file()
        assert "_commit: v0.18.6" in text
        # `template` here is the local checkout, which copier would otherwise record
        assert f"_src_path: {TEMPLATE_URL}" in text

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
