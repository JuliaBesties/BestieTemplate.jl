"""Unit tests for the bestie_template branding layer. No copier, no network."""

import pytest

import bestie_template
from copier_features.errors import RegistryFetchError, UnsupportedSchemaVersionError
from copier_features.registry import Registry


def test_bundled_registry_path_resolves_in_checkout(repo_root):
    assert bestie_template.bundled_registry_path() == repo_root / "features.toml"


def test_default_call_uses_bundled_registry(monkeypatch):
    # The README's no-arguments usage: remote default template, no ref
    monkeypatch.setattr(
        bestie_template, "fetch_registry", lambda *a, **k: pytest.fail("must not fetch")
    )
    names = [feature.name for feature in bestie_template.list_features()]
    assert "agents" in names and "pre_commit" in names


def test_local_template_dir_provides_registry(repo_root):
    registry = bestie_template.load_default_registry(str(repo_root))
    assert "agents" in registry.names()


def test_local_template_dir_without_registry_falls_back(tmp_path):
    registry = bestie_template.load_default_registry(str(tmp_path))
    assert "agents" in registry.names()  # bundled copy


def test_remote_with_ref_fetches_at_ref(monkeypatch, registry):
    seen = {}

    def fake_fetch(url, timeout=10.0):
        seen["url"] = url
        return registry

    monkeypatch.setattr(bestie_template, "fetch_registry", fake_fetch)
    result = bestie_template.load_default_registry(ref="v0.99.0")
    assert result is registry
    assert seen["url"] == (
        "https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/v0.99.0/features.toml"
    )


def test_remote_fetch_failure_warns_and_falls_back(monkeypatch):
    def fake_fetch(url, timeout=10.0):
        raise RegistryFetchError("network down")

    monkeypatch.setattr(bestie_template, "fetch_registry", fake_fetch)
    with pytest.warns(UserWarning, match="bundled copy"):
        result = bestie_template.load_default_registry(ref="v0.99.0")
    assert isinstance(result, Registry)
    assert "agents" in result.names()


def test_remote_schema_error_propagates(monkeypatch):
    def fake_fetch(url, timeout=10.0):
        raise UnsupportedSchemaVersionError("schema_version: 99")

    monkeypatch.setattr(bestie_template, "fetch_registry", fake_fetch)
    with pytest.raises(UnsupportedSchemaVersionError):
        bestie_template.load_default_registry(ref="v0.99.0")
