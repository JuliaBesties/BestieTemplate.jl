"""Typed errors raised by copier_features.

Frontends render these as short messages; raw tracebacks from copier are
wrapped in :class:`CopierRunError`.
"""


class CopierFeaturesError(Exception):
    """Base class for all copier_features errors."""


class MalformedRegistryError(CopierFeaturesError):
    """The features.toml registry violates the schema."""


class UnsupportedSchemaVersionError(MalformedRegistryError):
    """The registry declares a schema_version this engine does not know."""


class RegistryNotFoundError(CopierFeaturesError):
    """No features.toml registry could be located."""


class RegistryFetchError(CopierFeaturesError):
    """Fetching a remote features.toml failed (network or HTTP error)."""


class UnknownFeatureError(CopierFeaturesError):
    """The requested feature is not in the registry."""


class MissingRequiredFieldsError(CopierFeaturesError):
    """Required answer fields could not be resolved."""


class AnswersFileRequiredError(CopierFeaturesError):
    """The feature needs an existing .copier-answers.yml in the destination."""


class CopierRunError(CopierFeaturesError):
    """The underlying copier run failed."""
