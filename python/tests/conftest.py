from pathlib import Path

import pytest

import bestie_template


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


@pytest.fixture(scope="session")
def registry(repo_root: Path) -> dict:
    return bestie_template.load_registry(repo_root / "features.toml")


@pytest.fixture
def copier_calls(monkeypatch) -> list[dict]:
    """Stub the copier call, capturing its kwargs and creating the files it would render."""
    calls: list[dict] = []

    def fake_run_copy(**kwargs):
        calls.append(kwargs)
        for pattern in kwargs["exclude"]:
            if pattern.startswith("!"):
                path = Path(kwargs["dst_path"]) / pattern[1:]
                path.parent.mkdir(parents=True, exist_ok=True)
                path.touch()

    monkeypatch.setattr(bestie_template, "_run_copy", fake_run_copy)
    return calls
