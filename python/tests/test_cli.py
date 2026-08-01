"""The CLI: argument handling and output shape (the API itself is stubbed)."""

import json

import pytest

import bestie_template
from bestie_template.cli import main


@pytest.fixture
def fake_add_feature(monkeypatch):
    """Replace add_feature, capturing the (args, kwargs) the CLI passed it."""
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
    def test_splits_features_and_parses_data(self, fake_add_feature, capsys):
        code = main(["add-feature", "agents,testitem_cli", "pkg", "-d", "PackageName=Pkg"])
        assert code == 0
        (features, dst, data, kwargs) = fake_add_feature[0]
        assert features == ["agents", "testitem_cli"]
        assert (dst, data) == ("pkg", {"PackageName": "Pkg"})
        assert kwargs == {"ref": None, "template": bestie_template.TEMPLATE_URL}
        out = capsys.readouterr().out
        assert "Applied 2 feature(s) to pkg" in out
        assert "none was created" in out

    def test_json_output(self, fake_add_feature, capsys):
        assert main(["add-feature", "agents", "--json"]) == 0
        assert json.loads(capsys.readouterr().out)["applied"] == [
            {"name": "agents", "files": ["a.txt"]}
        ]

    def test_ref_and_template_are_forwarded(self, fake_add_feature):
        main(["add-feature", "agents", "--ref", "main", "--template", "/local/path"])
        assert fake_add_feature[0][3] == {"ref": "main", "template": "/local/path"}

    def test_trailing_comma_is_a_usage_error(self, fake_add_feature, capsys):
        """`bestie add-feature agents, changelog` must not treat `changelog` as the path."""
        with pytest.raises(SystemExit) as exit_info:
            main(["add-feature", "agents,", "changelog"])
        assert exit_info.value.code == 2
        assert "comma-separated" in capsys.readouterr().err
        assert fake_add_feature == []

    def test_malformed_data_is_a_usage_error(self, fake_add_feature):
        with pytest.raises(SystemExit) as exit_info:
            main(["add-feature", "agents", "-d", "PackageName"])
        assert exit_info.value.code == 2

    def test_errors_exit_1_with_the_message(self, monkeypatch, capsys):
        def fail(*args, **kwargs):
            raise bestie_template.BestieError("no such thing")

        monkeypatch.setattr(bestie_template.cli, "add_feature", fail)
        assert main(["add-feature", "nope"]) == 1
        assert "Error: no such thing" in capsys.readouterr().err

    def test_json_errors_are_json(self, monkeypatch, capsys):
        def fail(*args, **kwargs):
            raise bestie_template.BestieError("no such thing")

        monkeypatch.setattr(bestie_template.cli, "add_feature", fail)
        assert main(["add-feature", "nope", "--json"]) == 1
        assert json.loads(capsys.readouterr().out) == {"error": "no such thing"}


class TestListFeatures:
    def test_lists_descriptions_and_aliases(self, capsys):
        assert main(["list-features"]) == 0
        out = capsys.readouterr().out
        assert "agents" in out
        assert "pre_commit  " in out and "alias of pre_commit_with_config" in out

    def test_json_lists_every_entry(self, capsys, registry):
        assert main(["list-features", "--json"]) == 0
        features = json.loads(capsys.readouterr().out)
        assert [feature["name"] for feature in features] == sorted(registry)
