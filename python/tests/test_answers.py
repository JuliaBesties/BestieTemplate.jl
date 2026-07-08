"""Unit tests for answers-file reading."""

import pytest

from copier_features.answers import load_answers
from copier_features.errors import CopierFeaturesError


def test_underscore_keys_are_dropped(tmp_path):
    path = tmp_path / ".copier-answers.yml"
    path.write_text("PackageName: Pkg\n_commit: v1.0.0\n_src_path: gh:o/r\n")
    assert load_answers(path) == {"PackageName": "Pkg"}


def test_empty_file_is_empty_answers(tmp_path):
    path = tmp_path / ".copier-answers.yml"
    path.write_text("")
    assert load_answers(path) == {}


@pytest.mark.parametrize("content", ["[]", "false", "just a string", "- a\n- b"])
def test_non_mapping_content_raises(tmp_path, content):
    path = tmp_path / ".copier-answers.yml"
    path.write_text(content)
    with pytest.raises(CopierFeaturesError, match="expected a mapping"):
        load_answers(path)
