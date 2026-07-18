"""Tests for the `bestie` CLI (bestie_template.cli).

Unit tests stub the L2 operations on the bestie_template module (the CLI
looks them up at call time); the integration test at the bottom runs the
real pipeline against the local template checkout.
"""

import json

import pytest
from typer.testing import CliRunner

import bestie_template
from bestie_template.cli import app
from copier_features.errors import MissingRequiredFieldsError
from copier_features.ops import AddFeatureResult, AppliedFeature
from copier_features.registry import Feature

runner = CliRunner()

RESULT = AddFeatureResult(
    applied=(
        AppliedFeature(name="agents", resolved_name="agents", files=("AGENTS.md",)),
        AppliedFeature(
            name="pre_commit",
            resolved_name="pre_commit_with_config",
            files=(".pre-commit-config.yaml", ".JuliaFormatter.toml"),
        ),
    ),
    template="https://example.org/template",
    ref="v1.0.0",
    dst="/some/pkg",
    answers_file_updated=True,
)

FEATURES = [
    Feature(name="agents", description="Adds AGENTS.md"),
    Feature(name="pre_commit", alias_of="pre_commit_with_config"),
    Feature(name="pre_commit_with_config", description="Adds pre-commit config"),
]


@pytest.fixture
def stub_add_feature(monkeypatch):
    calls = []

    def fake(features, path, *, data, ref, template):
        calls.append(
            {"features": features, "path": path, "data": data, "ref": ref, "template": template}
        )
        return RESULT

    monkeypatch.setattr(bestie_template, "add_feature", fake)
    return calls


@pytest.fixture
def stub_list_features(monkeypatch):
    calls = []

    def fake(*, ref, template):
        calls.append({"ref": ref, "template": template})
        return FEATURES

    monkeypatch.setattr(bestie_template, "list_features", fake)
    return calls


def test_add_feature_parses_arguments(stub_add_feature):
    result = runner.invoke(
        app,
        [
            "add-feature",
            "agents, pre_commit",
            "/some/pkg",
            "-d",
            "PackageName=MyPkg",
            "--data",
            "Authors=Me <me@my.org>",
            "--ref",
            "v1.0.0",
            "--template",
            "tpl",
        ],
    )
    assert result.exit_code == 0
    assert stub_add_feature == [
        {
            "features": ["agents", "pre_commit"],
            "path": "/some/pkg",
            "data": {"PackageName": "MyPkg", "Authors": "Me <me@my.org>"},
            "ref": "v1.0.0",
            "template": "tpl",
        }
    ]
    assert "Applied 2 feature(s) to /some/pkg:" in result.output
    assert "pre_commit (-> pre_commit_with_config)" in result.output
    assert "Updated .copier-answers.yml" in result.output


def test_add_feature_defaults(stub_add_feature):
    result = runner.invoke(app, ["add-feature", "agents"])
    assert result.exit_code == 0
    call = stub_add_feature[0]
    assert call["path"] == "." and call["data"] == {}
    assert call["ref"] is None and call["template"] is None


def test_add_feature_json_result(stub_add_feature):
    result = runner.invoke(app, ["add-feature", "agents", "--json"])
    assert result.exit_code == 0
    payload = json.loads(result.output)
    assert payload["answers_file_updated"] is True
    assert payload["applied"][1]["resolved_name"] == "pre_commit_with_config"


def test_add_feature_bad_data_pair(stub_add_feature):
    result = runner.invoke(app, ["add-feature", "agents", "-d", "PackageName"])
    assert result.exit_code == 2
    assert not stub_add_feature


def test_add_feature_empty_features(stub_add_feature):
    result = runner.invoke(app, ["add-feature", " , "])
    assert result.exit_code == 2
    assert not stub_add_feature


def test_add_feature_space_after_comma(stub_add_feature):
    # `bestie add-feature X,Y, Z`: the shell hands typer FEATURES="X,Y," and
    # PATH="Z"; without the guard, Z would silently become the destination
    result = runner.invoke(app, ["add-feature", "agents,pre_commit,", "changelog"])
    assert result.exit_code == 2
    assert not stub_add_feature
    assert "did you mean 'agents,pre_commit,changelog'" in result.output


def test_typed_error_human(monkeypatch):
    def fake(*args, **kwargs):
        raise MissingRequiredFieldsError("Cannot determine required fields for 'agents'")

    monkeypatch.setattr(bestie_template, "add_feature", fake)
    result = runner.invoke(app, ["add-feature", "agents"])
    assert result.exit_code == 1
    assert "Error: Cannot determine required fields for 'agents'" in result.output


def test_typed_error_human_missing_fields_hint(monkeypatch):
    def fake(*args, **kwargs):
        raise MissingRequiredFieldsError(
            "Cannot determine required fields", missing=("PackageName", "Authors")
        )

    monkeypatch.setattr(bestie_template, "add_feature", fake)
    result = runner.invoke(app, ["add-feature", "agents"])
    assert result.exit_code == 1
    assert "Hint: pass the missing values on the command line: " in result.output
    assert "-d PackageName=... -d Authors=..." in result.output


def test_typed_error_json(monkeypatch):
    def fake(*args, **kwargs):
        raise MissingRequiredFieldsError("missing PackageName", missing=("PackageName",))

    monkeypatch.setattr(bestie_template, "add_feature", fake)
    result = runner.invoke(app, ["add-feature", "agents", "--json"])
    assert result.exit_code == 1
    payload = json.loads(result.output)
    assert payload["error"] == {
        "type": "MissingRequiredFieldsError",
        "message": "missing PackageName",
        "missing": ["PackageName"],
    }


def test_list_features_human(stub_list_features):
    result = runner.invoke(app, ["list-features"])
    assert result.exit_code == 0
    lines = result.output.splitlines()
    assert lines[0].startswith("agents") and "Adds AGENTS.md" in lines[0]
    assert "alias of pre_commit_with_config" in lines[1]
    assert stub_list_features == [{"ref": None, "template": None}]


def test_list_features_json(stub_list_features):
    result = runner.invoke(app, ["list-features", "--json", "--ref", "v1.0.0"])
    assert result.exit_code == 0
    payload = json.loads(result.output)
    assert [feature["name"] for feature in payload] == [
        "agents",
        "pre_commit",
        "pre_commit_with_config",
    ]
    assert payload[1]["alias_of"] == "pre_commit_with_config"
    assert stub_list_features == [{"ref": "v1.0.0", "template": None}]


def test_version():
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert result.output.strip()


@pytest.mark.integration
def test_cli_integration_add_feature(tmp_path, repo_root):
    result = runner.invoke(
        app,
        [
            "add-feature",
            "agents",
            str(tmp_path),
            "-d",
            "PackageName=FakePkg",
            "--template",
            str(repo_root),
            "--ref",
            "HEAD",
            "--json",
        ],
    )
    assert result.exit_code == 0, result.output
    agents_md = tmp_path / "AGENTS.md"
    assert agents_md.is_file() and "FakePkg" in agents_md.read_text()
    # copier may emit warnings before the JSON line; parse the last line
    payload = json.loads(result.output.strip().splitlines()[-1])
    assert payload["applied"][0]["files"] == ["AGENTS.md"]
    assert payload["answers_file_updated"] is False
