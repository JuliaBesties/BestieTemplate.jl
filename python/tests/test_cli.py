"""The CLI: argument handling and output shape (the API itself is stubbed)."""

import json

import pytest
from typer.testing import CliRunner

import bestie_template
import bestie_template.cli
from bestie_template.cli import app

runner = CliRunner()


def _raise(*args, **kwargs):
    raise bestie_template.BestieError("no such thing")


@pytest.fixture
def fake_add_feature(monkeypatch):
    """Replace add_feature, capturing the arguments the CLI passed it."""
    calls = []

    def fake(features, dst=".", data=None, **kwargs):
        calls.append((features, dst, data, kwargs))
        return {
            "dst": str(dst),
            "applied": [{"name": name, "files": ["a.txt"]} for name in features],
            "answers_file_updated": False,
        }

    monkeypatch.setattr(bestie_template.cli, "add_feature", fake)
    return calls


class TestAddFeature:
    def test_splits_features_and_parses_data(self, fake_add_feature):
        result = runner.invoke(
            app, ["add-feature", "agents,testitem_cli", "pkg", "-d", "PackageName=Pkg"]
        )
        assert result.exit_code == 0
        features, dst, data, kwargs = fake_add_feature[0]
        assert features == ["agents", "testitem_cli"]
        assert (dst, data) == ("pkg", {"PackageName": "Pkg"})
        assert kwargs == {"ref": None, "template": bestie_template.TEMPLATE_URL}
        assert "Applied 2 feature(s) to pkg" in result.stdout
        assert "none was created" in result.stdout

    def test_json_output(self, fake_add_feature):
        result = runner.invoke(app, ["add-feature", "agents", "--json"])
        assert result.exit_code == 0
        assert json.loads(result.stdout)["applied"] == [{"name": "agents", "files": ["a.txt"]}]

    def test_ref_and_template_are_forwarded(self, fake_add_feature):
        runner.invoke(app, ["add-feature", "agents", "--ref", "main", "--template", "/local/path"])
        assert fake_add_feature[0][3] == {"ref": "main", "template": "/local/path"}

    def test_trailing_comma_is_a_usage_error(self, fake_add_feature):
        """`bestie add-feature agents, changelog` must not treat `changelog` as the path."""
        result = runner.invoke(app, ["add-feature", "agents,", "changelog"])
        assert result.exit_code == 2
        assert fake_add_feature == []

    def test_malformed_data_is_a_usage_error(self, fake_add_feature):
        result = runner.invoke(app, ["add-feature", "agents", "-d", "PackageName"])
        assert result.exit_code == 2

    def test_errors_exit_1_with_the_message(self, monkeypatch):
        monkeypatch.setattr(bestie_template.cli, "add_feature", _raise)
        result = runner.invoke(app, ["add-feature", "nope"])
        assert result.exit_code == 1
        assert "Error: no such thing" in result.stderr

    def test_json_errors_are_json(self, monkeypatch):
        monkeypatch.setattr(bestie_template.cli, "add_feature", _raise)
        result = runner.invoke(app, ["add-feature", "nope", "--json"])
        assert result.exit_code == 1
        assert json.loads(result.stdout) == {"error": "no such thing"}


class TestListFeatures:
    def test_lists_descriptions_and_aliases(self, monkeypatch):
        # No entry in the real registry is currently an alias (#625 removed the last
        # one); exercise the CLI's rendering of both shapes directly.
        monkeypatch.setattr(
            bestie_template.cli,
            "list_features",
            lambda: [
                {"name": "agents", "description": "Adds AGENTS.md"},
                {"name": "pre_commit_alias", "alias_of": "pre_commit"},
            ],
        )
        result = runner.invoke(app, ["list-features"])
        assert result.exit_code == 0
        assert "Adds AGENTS.md" in result.stdout
        assert "alias of pre_commit" in result.stdout

    def test_json_lists_every_entry(self, registry):
        result = runner.invoke(app, ["list-features", "--json"])
        assert result.exit_code == 0
        assert [feature["name"] for feature in json.loads(result.stdout)] == sorted(registry)


def test_version_prints_the_package_version():
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert result.stdout.strip() == bestie_template.cli._package_version("bestie-template")
