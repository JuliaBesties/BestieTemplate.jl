"""BestieTemplate branding over the generic copier_features engine.

Supplies Bestie's defaults (template URL, registry resolution, placeholder
fields) and re-exports the operations with those defaults baked in. Every
default is overridable: `template` accepts any URL or local path, and `ref`
any git ref of the template.
"""

from __future__ import annotations

import warnings
from pathlib import Path
from typing import Any

from copier_features.errors import RegistryFetchError, RegistryNotFoundError
from copier_features.ops import AddFeatureResult, AppliedFeature
from copier_features.ops import add_feature as _generic_add_feature
from copier_features.registry import (
    REGISTRY_FILENAME,
    Feature,
    Registry,
    fetch_registry,
    github_raw_registry_url,
    load_registry,
)

__all__ = [
    "PLACEHOLDER_FIELDS",
    "TEMPLATE_URL",
    "AddFeatureResult",
    "AppliedFeature",
    "Feature",
    "Registry",
    "add_feature",
    "bundled_registry_path",
    "list_features",
    "load_default_registry",
]

TEMPLATE_URL = "https://github.com/JuliaBesties/BestieTemplate.jl"

# Questions copier requires answered even when a feature's files don't use
# them; filled with a placeholder when unresolved (mirrors the Julia add_feature).
PLACEHOLDER_FIELDS = ("PackageName", "PackageOwner", "Authors")


def bundled_registry_path() -> Path:
    """Path of the registry copy that ships with this package.

    Wheels built from the sdist carry it next to this module; in a repository
    checkout it is the repo-root features.toml (the single source of truth).
    """
    candidates = (
        Path(__file__).with_name(REGISTRY_FILENAME),
        Path(__file__).parents[3] / REGISTRY_FILENAME,
    )
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    raise RegistryNotFoundError(
        f"No bundled {REGISTRY_FILENAME} found (tried {', '.join(str(c) for c in candidates)})"
    )


def _is_remote_template(template: str) -> bool:
    return "://" in template or template.startswith("git@")


def load_default_registry(template: str | None = None, ref: str | None = None) -> Registry:
    """Resolve the feature registry for `template` at `ref`.

    A local template directory provides its own registry (with the bundled
    copy as fallback). For a GitHub template URL with an explicit `ref`, the
    registry is fetched at that same ref so feature definitions match the
    template version being applied; a network failure falls back to the
    bundled copy with a warning, but a registry that is invalid or declares
    an unsupported schema_version raises. Without a `ref`, the bundled copy
    is used — which may be newer than the template release copier picks by
    default (known limitation, see design/02-features-toml.md).
    """
    template = template or TEMPLATE_URL
    if not _is_remote_template(template):
        template_dir = Path(template)
        if template_dir.is_dir():
            local = template_dir / REGISTRY_FILENAME
            return load_registry(local if local.is_file() else bundled_registry_path())
    elif ref is not None:
        url = github_raw_registry_url(template, ref)
        if url is not None:
            try:
                return fetch_registry(url)
            except RegistryFetchError as exc:
                warnings.warn(
                    f"Could not fetch {REGISTRY_FILENAME} for ref {ref!r}; "
                    f"using the bundled copy instead ({exc})",
                    stacklevel=2,
                )
    return load_registry(bundled_registry_path())


def add_feature(
    features: list[str],
    dst: str | Path = ".",
    data: dict[str, Any] | None = None,
    *,
    ref: str | None = None,
    template: str | None = None,
    registry: Registry | None = None,
) -> AddFeatureResult:
    """Apply BestieTemplate features (in order) to the project at `dst`.

    See :func:`copier_features.ops.add_feature` for the merge and
    answers-file semantics.
    """
    template = template or TEMPLATE_URL
    if registry is None:
        registry = load_default_registry(template, ref)
    return _generic_add_feature(
        features,
        dst,
        template=template,
        registry=registry,
        data=data,
        ref=ref,
        placeholder_fields=PLACEHOLDER_FIELDS,
    )


def list_features(
    *,
    ref: str | None = None,
    template: str | None = None,
    registry: Registry | None = None,
) -> list[Feature]:
    """All available features (aliases included), sorted by name."""
    if registry is None:
        registry = load_default_registry(template, ref)
    return registry.list()
