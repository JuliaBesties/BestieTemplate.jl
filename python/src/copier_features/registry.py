"""Loading and validating the features.toml registry."""

from __future__ import annotations

import re
import tomllib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any
from urllib.parse import quote
from urllib.request import urlopen

from .errors import (
    MalformedRegistryError,
    RegistryFetchError,
    RegistryNotFoundError,
    UnknownFeatureError,
    UnsupportedSchemaVersionError,
)

SUPPORTED_SCHEMA_VERSION = 1
REGISTRY_FILENAME = "features.toml"


@dataclass(frozen=True)
class Feature:
    """One entry of the registry. Alias entries only carry ``alias_of``."""

    name: str
    description: str = ""
    forced_data: dict[str, Any] = field(default_factory=dict)
    included_files: tuple[str, ...] = ()
    required_fields: tuple[str, ...] = ()
    requires_answers: bool = False
    alias_of: str | None = None


@dataclass(frozen=True)
class Registry:
    """The parsed feature registry, aliases included."""

    features: dict[str, Feature]

    def names(self) -> list[str]:
        return sorted(self.features)

    def list(self) -> list[Feature]:
        return [self.features[name] for name in self.names()]

    def resolve(self, name: str) -> Feature:
        """Return the (alias-resolved) feature named `name`."""
        if name not in self.features:
            supported = ", ".join(self.names())
            raise UnknownFeatureError(f"Unknown feature {name!r}. Supported features: {supported}")
        feature = self.features[name]
        if feature.alias_of is not None:
            feature = self.features[feature.alias_of]
        return feature


def _check_type(name: str, key: str, value: Any, expected: type, type_name: str) -> None:
    if not isinstance(value, expected):
        raise MalformedRegistryError(f"features.toml: [features.{name}] {key} must be {type_name}")


def _parse_feature(name: str, spec: Any) -> Feature:
    if not isinstance(spec, dict):
        raise MalformedRegistryError(f"features.toml: [features.{name}] must be a table")

    if "alias_of" in spec:
        if set(spec) != {"alias_of"}:
            raise MalformedRegistryError(
                f"features.toml: alias [features.{name}] must have exactly one key, alias_of"
            )
        _check_type(name, "alias_of", spec["alias_of"], str, "a string")
        return Feature(name=name, alias_of=spec["alias_of"])

    required_keys = (
        "description",
        "forced_data",
        "included_files",
        "required_fields",
        "requires_answers",
    )
    for key in required_keys:
        if key not in spec:
            raise MalformedRegistryError(f"features.toml: [features.{name}] is missing {key}")
    _check_type(name, "description", spec["description"], str, "a string")
    _check_type(name, "forced_data", spec["forced_data"], dict, "a table")
    _check_type(name, "requires_answers", spec["requires_answers"], bool, "a boolean")
    for key in ("included_files", "required_fields"):
        _check_type(name, key, spec[key], list, "an array of strings")
        if not all(isinstance(item, str) for item in spec[key]):
            raise MalformedRegistryError(
                f"features.toml: [features.{name}] {key} must be an array of strings"
            )

    return Feature(
        name=name,
        description=spec["description"],
        forced_data=dict(spec["forced_data"]),
        included_files=tuple(spec["included_files"]),
        required_fields=tuple(spec["required_fields"]),
        requires_answers=spec["requires_answers"],
    )


def parse_registry(raw: dict[str, Any]) -> Registry:
    """Validate a parsed TOML document and build the :class:`Registry`."""
    schema_version = raw.get("schema_version")
    if schema_version != SUPPORTED_SCHEMA_VERSION:
        raise UnsupportedSchemaVersionError(
            f"Unsupported features.toml schema_version: {schema_version!r}. "
            f"This engine supports schema_version {SUPPORTED_SCHEMA_VERSION}; "
            "try updating the package."
        )
    if not isinstance(raw.get("features"), dict) or not raw["features"]:
        raise MalformedRegistryError("features.toml: missing or empty [features] table")

    features = {name: _parse_feature(name, spec) for name, spec in raw["features"].items()}
    for name, feature in features.items():
        if feature.alias_of is None:
            continue
        target = features.get(feature.alias_of)
        if target is None:
            raise MalformedRegistryError(
                f"features.toml: {name} is an alias of unknown feature {feature.alias_of}"
            )
        if target.alias_of is not None:
            raise MalformedRegistryError(
                f"features.toml: alias chains are not supported "
                f"({name} -> {feature.alias_of} -> {target.alias_of})"
            )
    return Registry(features=features)


def load_registry(path: str | Path) -> Registry:
    """Load the registry from a features.toml file."""
    try:
        with open(path, "rb") as handle:
            try:
                raw = tomllib.load(handle)
            except tomllib.TOMLDecodeError as exc:
                raise MalformedRegistryError(
                    f"features.toml: invalid TOML in {path}: {exc}"
                ) from exc
    except FileNotFoundError as exc:
        raise RegistryNotFoundError(f"No {REGISTRY_FILENAME} found at {path}") from exc
    return parse_registry(raw)


def github_raw_registry_url(template_url: str, ref: str) -> str | None:
    """Build the raw URL of a GitHub-hosted template's registry at `ref`.

    Returns None when `template_url` is not a GitHub repository URL.
    Raises ValueError for refs that are not valid single git ref names
    (empty, ".", ".." or leading "-" segments) — the raw CDN would resolve
    ".." segments and serve a different repository.
    """
    match = re.match(
        r"(?:https://|git@)github\.com[:/]([^/?#]+)/([^/?#]+?)(?:\.git)?/?$",
        template_url,
        re.IGNORECASE,
    )
    if match is None:
        return None
    segments = ref.split("/")
    if any(segment in ("", ".", "..") or segment.startswith("-") for segment in segments):
        raise ValueError(f"Invalid template ref: {ref!r}")
    owner, repo = match.groups()
    safe_ref = quote(ref, safe="/")
    return f"https://raw.githubusercontent.com/{owner}/{repo}/{safe_ref}/{REGISTRY_FILENAME}"


def fetch_registry(url: str, timeout: float = 10.0) -> Registry:
    """Fetch and parse a registry from an HTTPS URL.

    Network and HTTP failures raise :class:`RegistryFetchError`; a body that
    is not a valid registry raises the usual registry errors.
    """
    try:
        with urlopen(url, timeout=timeout) as response:
            text = response.read().decode("utf-8")
    except OSError as exc:
        raise RegistryFetchError(f"Could not fetch {url}: {exc}") from exc
    try:
        raw = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise MalformedRegistryError(f"features.toml: invalid TOML at {url}: {exc}") from exc
    return parse_registry(raw)
