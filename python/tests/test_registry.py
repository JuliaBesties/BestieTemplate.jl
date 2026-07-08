"""Unit tests for registry parsing and validation. No copier, no network."""

import tomllib

import pytest

from copier_features.errors import (
    MalformedRegistryError,
    UnknownFeatureError,
    UnsupportedSchemaVersionError,
)
from copier_features.registry import github_raw_registry_url, parse_registry

VALID_MINIMAL = """
schema_version = 1

[features.thing]
description = "Adds a thing"
forced_data = { AddThing = true }
included_files = ["thing.txt"]
required_fields = []
requires_answers = false
"""


def _parse(toml_text: str):
    return parse_registry(tomllib.loads(toml_text))


class TestRepoRegistry:
    """The repository's own features.toml is the reference fixture; these
    expectations mirror the Julia suite (test/test-add-feature.jl)."""

    def test_feature_names(self, registry):
        assert registry.names() == [
            "agents",
            "changelog",
            "dependabot",
            "lint_action",
            "pre_commit",
            "pre_commit_with_config",
            "pre_commit_without_config",
            "testitem_cli",
        ]

    def test_agents_spec(self, registry):
        agents = registry.resolve("agents")
        assert agents.forced_data == {"AddAgentsMd": True}
        assert agents.included_files == ("AGENTS.md",)
        assert agents.required_fields == ("PackageName",)
        assert agents.requires_answers is False
        assert agents.description

    def test_lint_action_requires_answers(self, registry):
        assert registry.resolve("lint_action").requires_answers is True

    def test_alias_resolves_to_target(self, registry):
        assert registry.resolve("pre_commit").name == "pre_commit_with_config"
        assert len(registry.resolve("pre_commit").included_files) == 6

    def test_aliases_are_listed(self, registry):
        by_name = {feature.name: feature for feature in registry.list()}
        assert by_name["pre_commit"].alias_of == "pre_commit_with_config"

    def test_unknown_feature(self, registry):
        with pytest.raises(UnknownFeatureError, match=r"Supported features:.*pre_commit"):
            registry.resolve("nonexistent_feature")


class TestValidation:
    def test_valid_minimal(self):
        registry = _parse(VALID_MINIMAL)
        assert registry.resolve("thing").forced_data == {"AddThing": True}

    def test_unsupported_schema_version(self):
        with pytest.raises(UnsupportedSchemaVersionError, match="schema_version: 2"):
            _parse(VALID_MINIMAL.replace("schema_version = 1", "schema_version = 2"))

    def test_missing_schema_version(self):
        with pytest.raises(UnsupportedSchemaVersionError):
            _parse("[features.x]\ndescription = 'x'")

    def test_missing_features_table(self):
        with pytest.raises(MalformedRegistryError, match=r"\[features\]"):
            _parse("schema_version = 1")

    @pytest.mark.parametrize(
        "key",
        ["description", "forced_data", "included_files", "required_fields", "requires_answers"],
    )
    def test_missing_required_key(self, key):
        lines = [line for line in VALID_MINIMAL.splitlines() if not line.startswith(key)]
        with pytest.raises(MalformedRegistryError, match=f"missing {key}"):
            _parse("\n".join(lines))

    def test_alias_to_unknown_target(self):
        with pytest.raises(MalformedRegistryError, match="unknown feature"):
            _parse(VALID_MINIMAL + '\n[features.other]\nalias_of = "missing"\n')

    def test_alias_chain(self):
        with pytest.raises(MalformedRegistryError, match="alias chains"):
            _parse(
                VALID_MINIMAL
                + '\n[features.a]\nalias_of = "thing"\n\n[features.b]\nalias_of = "a"\n'
            )

    def test_alias_with_extra_keys(self):
        with pytest.raises(MalformedRegistryError, match="exactly one key"):
            _parse(VALID_MINIMAL + '\n[features.other]\nalias_of = "thing"\ndescription = "x"\n')

    def test_included_files_wrong_type(self):
        with pytest.raises(MalformedRegistryError, match="array of strings"):
            _parse(VALID_MINIMAL.replace('included_files = ["thing.txt"]', "included_files = [1]"))


class TestGithubRawUrl:
    def test_https_url(self):
        url = github_raw_registry_url("https://github.com/JuliaBesties/BestieTemplate.jl", "v1.2.3")
        assert (
            url
            == "https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/v1.2.3/features.toml"
        )

    @pytest.mark.parametrize(
        "template",
        [
            "https://github.com/Owner/Repo.git",
            "git@github.com:Owner/Repo.git",
            "https://github.com/Owner/Repo/",
        ],
    )
    def test_url_variants(self, template):
        assert (
            github_raw_registry_url(template, "HEAD")
            == "https://raw.githubusercontent.com/Owner/Repo/HEAD/features.toml"
        )

    def test_non_github_url(self):
        assert github_raw_registry_url("https://gitlab.com/o/r", "HEAD") is None
        assert github_raw_registry_url("/local/path", "HEAD") is None
        assert github_raw_registry_url("https://github.com/o/r?x=1", "HEAD") is None

    def test_case_insensitive_host(self):
        assert github_raw_registry_url("https://GitHub.com/Owner/Repo", "HEAD") is not None

    @pytest.mark.parametrize("ref", ["../../evil/repo/main", "a//b", ".", "-option", "x/.."])
    def test_path_traversal_refs_are_rejected(self, ref):
        with pytest.raises(ValueError, match="Invalid template ref"):
            github_raw_registry_url("https://github.com/Owner/Repo", ref)

    def test_ref_with_special_characters_is_encoded(self):
        url = github_raw_registry_url("https://github.com/Owner/Repo", "feat branch")
        assert url == "https://raw.githubusercontent.com/Owner/Repo/feat%20branch/features.toml"


class TestLoadAndFetch:
    def test_load_registry_missing_file(self, tmp_path):
        from copier_features.errors import RegistryNotFoundError
        from copier_features.registry import load_registry

        with pytest.raises(RegistryNotFoundError, match=r"No features\.toml"):
            load_registry(tmp_path / "features.toml")

    def test_fetch_registry_parses_body(self, monkeypatch):
        import copier_features.registry as registry_module

        class FakeResponse:
            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def read(self):
                return VALID_MINIMAL.encode()

        monkeypatch.setattr(registry_module, "urlopen", lambda url, timeout: FakeResponse())
        registry = registry_module.fetch_registry("https://example.invalid/features.toml")
        assert registry.resolve("thing").included_files == ("thing.txt",)

    def test_fetch_registry_network_error(self, monkeypatch):
        import copier_features.registry as registry_module
        from copier_features.errors import RegistryFetchError

        def failing_urlopen(url, timeout):
            raise OSError("connection refused")

        monkeypatch.setattr(registry_module, "urlopen", failing_urlopen)
        with pytest.raises(RegistryFetchError, match="connection refused"):
            registry_module.fetch_registry("https://example.invalid/features.toml")
