"""Add BestieTemplate features to an existing Julia package, without Julia.

A port of `BestieTemplate.add_feature` (src/friendly.jl): both read the same
`features.toml` registry at the repository root, and apply a feature by running
copier with everything but the feature's files excluded.
"""

from __future__ import annotations

import errno
import shutil
import tomllib
from pathlib import Path, PurePath
from typing import Any

import yaml

__all__ = ["TEMPLATE_URL", "BestieError", "add_feature", "list_features", "load_registry"]

TEMPLATE_URL = "https://github.com/JuliaBesties/BestieTemplate.jl"
REGISTRY_FILENAME = "features.toml"
ANSWERS_FILENAME = ".copier-answers.yml"
SCHEMA_VERSION = 1

# Questions copier requires answered even when a feature's files don't use
# them; filled with a placeholder when unresolved (mirrors the Julia side).
PLACEHOLDER_FIELDS = ("PackageName", "PackageOwner", "Authors")
PLACEHOLDER_VALUE = "UNUSED"


class BestieError(Exception):
    """Anything the user can act on: bad feature name, missing answer, failed copier run."""


def registry_path() -> Path:
    """Path of the feature registry: bundled in a wheel, the repo root in a checkout."""
    candidates = (
        Path(__file__).with_name(REGISTRY_FILENAME),
        Path(__file__).parents[3] / REGISTRY_FILENAME,
    )
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    raise BestieError(f"No {REGISTRY_FILENAME} found (tried {', '.join(map(str, candidates))})")


def load_registry(path: str | Path | None = None) -> dict[str, dict[str, Any]]:
    """Load the `[features]` table of a `features.toml` registry."""
    with open(path or registry_path(), "rb") as handle:
        raw = tomllib.load(handle)
    if raw.get("schema_version") != SCHEMA_VERSION:
        raise BestieError(
            f"Unsupported {REGISTRY_FILENAME} schema_version: {raw.get('schema_version')!r}. "
            f"This version only supports schema_version {SCHEMA_VERSION}; try updating the package."
        )
    return raw["features"]


def list_features(registry: dict[str, dict[str, Any]] | None = None) -> list[dict[str, Any]]:
    """Every registry entry, aliases included, sorted by name."""
    features = load_registry() if registry is None else registry
    return [{"name": name, **spec} for name, spec in sorted(features.items())]


def add_feature(
    features: list[str],
    dst: str | Path = ".",
    data: dict[str, Any] | None = None,
    *,
    ref: str | None = None,
    template: str = TEMPLATE_URL,
    registry: dict[str, dict[str, Any]] | None = None,
) -> dict[str, Any]:
    """Apply `features` (in order) to the package at `dst`.

    Data is merged as (later wins): the answers file -> `data` -> the feature's
    `forced_data`. `.copier-answers.yml` is updated when it already exists, and
    is never created.
    """
    registry = load_registry() if registry is None else registry
    dst = Path(dst)
    answers_path = dst / ANSWERS_FILENAME
    has_answers = answers_path.is_file()
    base_data = _load_answers(answers_path) if has_answers else {}

    # Validate the whole batch before the first copier run, so a bad feature at
    # position k does not leave features < k applied. Merging only adds keys
    # between runs, so passing here guarantees it for the runs below too.
    specs = []
    for name in features:
        spec = _resolve(registry, name)
        if spec["requires_answers"] and not has_answers:
            raise BestieError(
                f"Feature {name!r} requires {ANSWERS_FILENAME} in {dst} to determine template "
                "options. Apply the full template first to create it."
            )
        missing = [
            field
            for field in spec["required_fields"]
            if field not in {**base_data, **(data or {}), **spec["forced_data"]}
        ]
        if missing:
            raise BestieError(
                f"Cannot determine required fields for {name!r}: {', '.join(missing)}. "
                f"Pass them as data ({' '.join(f'-d {field}=...' for field in missing)})."
            )
        specs.append(spec)

    applied = []
    for name, spec in zip(features, specs, strict=True):
        merged = {**base_data, **(data or {}), **spec["forced_data"]}
        for field in PLACEHOLDER_FIELDS:
            merged.setdefault(field, PLACEHOLDER_VALUE)
        included = list(spec["included_files"])
        # Files the feature's output needs when a flag is on, added only when missing so a
        # config the user already tuned survives (see optional_files in features.toml).
        for field, files in spec.get("optional_files", {}).items():
            if _is_true(merged.get(field)):
                included += [file for file in files if not (dst / file).exists()]
        exclude = ["**", *(f"!{file}" for file in included)]
        if has_answers:
            exclude.append(f"!{ANSWERS_FILENAME}")

        _run_copy(
            src_path=template,
            dst_path=str(dst),
            data=merged,
            exclude=exclude,
            overwrite=True,
            defaults=True,
            quiet=True,
            vcs_ref=ref,
        )

        required_files = spec["included_files"]
        if not any((dst / file).exists() for file in required_files):
            raise BestieError(
                f"Feature {name!r} produced none of its files ({', '.join(required_files)}). The "
                f"rendered template ref ({ref or 'the latest release'}) probably predates this "
                "feature; pass a ref of a template version that includes it."
            )
        if has_answers:
            # copier rewrote the answers file; let later features in this batch
            # see it, exactly as sequential single-feature calls would
            base_data = _load_answers(answers_path)
        applied.append({"name": name, "files": included})

    return {"dst": str(dst), "applied": applied, "answers_file_updated": has_answers}


def _is_true(value: Any) -> bool:
    """Whether an answer means boolean true.

    Values reaching us from `-d FLAG=false` are the *string* `"false"`, which is truthy in
    Python; copier only coerces them at render time. So never test these flags directly.
    """
    if isinstance(value, str):
        return value.strip().lower() == "true"
    return value is True


def _resolve(registry: dict[str, dict[str, Any]], name: str) -> dict[str, Any]:
    """The spec of `name`, following an alias to the entry it points at."""
    if name not in registry:
        raise BestieError(
            f"Unknown feature {name!r}. Supported features: {', '.join(sorted(registry))}"
        )
    spec = registry[name]
    alias = spec.get("alias_of")
    if alias is None:
        return spec
    if alias not in registry or "alias_of" in registry[alias]:
        raise BestieError(f"{REGISTRY_FILENAME} is malformed: bad alias {name!r} -> {alias!r}")
    return registry[alias]


def _load_answers(path: Path) -> dict[str, Any]:
    """An answers file without copier's internal (underscore-prefixed) keys."""
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    if not isinstance(data, dict):
        raise BestieError(f"Not a valid answers file (expected a mapping): {path}")
    return {key: value for key, value in data.items() if not key.startswith("_")}


def _run_copy(**kwargs: Any) -> None:
    # The module-level indirection is also the seam the unit tests stub out
    import copier

    try:
        copier.run_copy(**kwargs)
    except Exception as exc:
        leftover_clone = _cleanup_race_dir(exc)
        if leftover_clone is None:
            raise BestieError(f"copier failed: {exc}") from exc
        shutil.rmtree(leftover_clone, ignore_errors=True)


def _cleanup_race_dir(exc: Exception) -> str | None:
    """The temporary clone copier failed to remove, or None if `exc` is a real failure.

    Copier removes its temporary clone only after the requested operation has
    fully completed, and on Linux that rmtree intermittently fails with
    `OSError: [Errno 39] Directory not empty` — the destination files are
    already in place. Same workaround as `Copier._ignore_cleanup_race` (Julia).
    """
    if not isinstance(exc, OSError) or exc.errno != errno.ENOTEMPTY:
        return None
    if not isinstance(exc.filename, str):
        return None
    parts = PurePath(exc.filename).parts
    for index, part in enumerate(parts):
        if part.startswith("copier._vcs.clone."):
            return str(PurePath(*parts[: index + 1]))
    return None
