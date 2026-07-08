"""Invariant: the generic engine never references the branding package.

See design/03-generic-vs-branding.md — copier_features must remain
publishable on its own, so extraction stays a file move.
"""

from pathlib import Path

import copier_features


def test_copier_features_never_mentions_bestie():
    package_dir = Path(copier_features.__file__).parent
    sources = list(package_dir.rglob("*.py"))
    assert sources, "no sources found — did the package layout change?"
    for source in sources:
        assert "bestie" not in source.read_text(encoding="utf-8").lower(), (
            f"{source.name} references the branding package"
        )
