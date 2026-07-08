"""The L2 operations: add_feature and list_features.

These compose the registry, answers, and merge logic around a single copier
call per feature. They do no printing and return structured results;
presentation belongs to the frontends.
"""

from __future__ import annotations

import errno
import shutil
from dataclasses import dataclass
from pathlib import Path, PurePath
from typing import Any

from .answers import ANSWERS_FILENAME, load_answers
from .errors import AnswersFileRequiredError, CopierRunError, MissingRequiredFieldsError
from .registry import Feature, Registry

PLACEHOLDER_VALUE = "UNUSED"


@dataclass(frozen=True)
class AppliedFeature:
    """One feature that was applied, after alias resolution."""

    name: str
    resolved_name: str
    files: tuple[str, ...]


@dataclass(frozen=True)
class AddFeatureResult:
    applied: tuple[AppliedFeature, ...]
    template: str
    ref: str | None
    dst: str
    answers_file_updated: bool


def build_exclude(included_files: tuple[str, ...], update_answers_file: bool) -> list[str]:
    """Exclude everything except the feature's files (and the answers file when updating it)."""
    exclude = ["**", *(f"!{path}" for path in included_files)]
    if update_answers_file:
        exclude.append(f"!{ANSWERS_FILENAME}")
    return exclude


def _copier_cleanup_race_dir(exc: OSError) -> str | None:
    """If `exc` is copier failing to remove its own temporary VCS clone, return that clone's path.

    Copier removes its temporary clone only after the requested operation has
    fully completed, and on Linux that rmtree intermittently fails with
    ``OSError: [Errno 39] Directory not empty``. The destination files are
    already in place at that point. (Same workaround as the Julia side's
    ``Copier._ignore_cleanup_race``.)
    """
    if exc.errno != errno.ENOTEMPTY or not isinstance(exc.filename, str):
        return None
    parts = PurePath(exc.filename).parts
    for index, part in enumerate(parts):
        if part.startswith("copier._vcs.clone."):
            return str(PurePath(*parts[: index + 1]))
    return None


def _run_copy(**kwargs: Any) -> None:
    # Module-level indirection so tests can substitute the copier call
    import copier

    try:
        copier.run_copy(**kwargs)
    except OSError as exc:
        leftover_clone = _copier_cleanup_race_dir(exc)
        if leftover_clone is None:
            raise
        shutil.rmtree(leftover_clone, ignore_errors=True)


def add_feature(
    features: list[str],
    dst: str | Path,
    *,
    template: str,
    registry: Registry,
    data: dict[str, Any] | None = None,
    ref: str | None = None,
    placeholder_fields: tuple[str, ...] = (),
) -> AddFeatureResult:
    """Apply `features` (in order) to the project at `dst`.

    For each feature, data is merged as (later wins): answers file ->
    explicit `data` -> the feature's `forced_data`. Fields in
    `placeholder_fields` that the template requires but the feature's files
    don't use are filled with a placeholder when unresolved. The answers file
    is updated when it already exists and is never created.
    """
    dst_path = Path(dst)
    answers_path = dst_path / ANSWERS_FILENAME
    has_answers = answers_path.is_file()
    base_data = load_answers(answers_path) if has_answers else {}

    # Validate the whole batch before the first copier run, so a bad feature
    # at position k does not leave features < k already applied. Data merges
    # only add keys between runs, so passing validation here guarantees it
    # for the actual runs below.
    resolved: list[Feature] = []
    for name in features:
        feature = registry.resolve(name)
        if feature.requires_answers and not has_answers:
            raise AnswersFileRequiredError(
                f"Feature {name!r} requires {ANSWERS_FILENAME} in {dst_path} to determine "
                "template options. Apply the full template first to create it."
            )
        merged = {**base_data, **(data or {}), **feature.forced_data}
        missing = [key for key in feature.required_fields if key not in merged]
        if missing:
            raise MissingRequiredFieldsError(
                f"Cannot determine required fields for {name!r}: {', '.join(missing)}. "
                "Pass them via the data argument."
            )
        resolved.append(feature)

    applied: list[AppliedFeature] = []
    for name, feature in zip(features, resolved, strict=True):
        merged = {**base_data, **(data or {}), **feature.forced_data}
        for key in placeholder_fields:
            merged.setdefault(key, PLACEHOLDER_VALUE)

        try:
            _run_copy(
                src_path=template,
                dst_path=str(dst_path),
                data=merged,
                exclude=build_exclude(feature.included_files, has_answers),
                overwrite=True,
                defaults=True,
                quiet=True,
                vcs_ref=ref,
            )
        except Exception as exc:
            raise CopierRunError(f"copier failed while applying {name!r}: {exc}") from exc

        if has_answers:
            # copier rewrote the answers file; make later features in this
            # batch see it, exactly as sequential single-feature calls would
            base_data = load_answers(answers_path)
        applied.append(
            AppliedFeature(name=name, resolved_name=feature.name, files=feature.included_files)
        )

    return AddFeatureResult(
        applied=tuple(applied),
        template=template,
        ref=ref,
        dst=str(dst_path),
        answers_file_updated=has_answers,
    )


def list_features(registry: Registry) -> list[Feature]:
    """All registry entries (aliases included), sorted by name."""
    return registry.list()
