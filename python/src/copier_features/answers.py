"""Reading copier answers files (.copier-answers.yml)."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from .errors import CopierFeaturesError

ANSWERS_FILENAME = ".copier-answers.yml"


def load_answers(path: str | Path) -> dict[str, Any]:
    """Read an answers file, dropping copier-internal keys (leading underscore)."""
    with open(path, encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if data is None:
        data = {}
    if not isinstance(data, dict):
        raise CopierFeaturesError(f"Not a valid answers file (expected a mapping): {path}")
    return {key: value for key, value in data.items() if not key.startswith("_")}
