from pathlib import Path

import pytest

from copier_features.registry import Registry, load_registry

REPO_ROOT = Path(__file__).resolve().parents[2]


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return REPO_ROOT


@pytest.fixture(scope="session")
def registry_path(repo_root: Path) -> Path:
    return repo_root / "features.toml"


@pytest.fixture(scope="session")
def registry(registry_path: Path) -> Registry:
    return load_registry(registry_path)
