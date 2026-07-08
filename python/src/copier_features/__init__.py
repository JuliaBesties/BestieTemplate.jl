"""Generic engine for feature-sliced regeneration of copier templates.

A template opts in by shipping a ``features.toml`` registry at its repository
root; this package loads that registry and applies individual features by
running copier restricted to each feature's files.

This package is template-agnostic by design: it must not import or mention
any specific template (branding lives in separate packages).
"""

from .errors import (
    AnswersFileRequiredError,
    CopierFeaturesError,
    CopierRunError,
    MalformedRegistryError,
    MissingRequiredFieldsError,
    RegistryFetchError,
    RegistryNotFoundError,
    UnknownFeatureError,
    UnsupportedSchemaVersionError,
)
from .ops import AddFeatureResult, AppliedFeature, add_feature, list_features
from .registry import (
    REGISTRY_FILENAME,
    SUPPORTED_SCHEMA_VERSION,
    Feature,
    Registry,
    fetch_registry,
    github_raw_registry_url,
    load_registry,
    parse_registry,
)

__all__ = [
    "REGISTRY_FILENAME",
    "SUPPORTED_SCHEMA_VERSION",
    "AddFeatureResult",
    "AnswersFileRequiredError",
    "AppliedFeature",
    "CopierFeaturesError",
    "CopierRunError",
    "Feature",
    "MalformedRegistryError",
    "MissingRequiredFieldsError",
    "Registry",
    "RegistryFetchError",
    "RegistryNotFoundError",
    "UnknownFeatureError",
    "UnsupportedSchemaVersionError",
    "add_feature",
    "fetch_registry",
    "github_raw_registry_url",
    "list_features",
    "load_registry",
    "parse_registry",
]
