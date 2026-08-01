"""Bundle the repo-root features.toml into the package at build time.

The registry's single source of truth is ../features.toml, shared with the
Julia package, so it cannot simply live inside this directory. Editable
installs need no copy (the runtime falls back to the repo-root file, see
bestie_template.registry_path).
"""

from pathlib import Path

from hatchling.builders.hooks.plugin.interface import BuildHookInterface

IN_PACKAGE = Path("src") / "bestie_template" / "features.toml"


class BundleRegistryHook(BuildHookInterface):
    def initialize(self, version: str, build_data: dict) -> None:
        if version == "editable" or (Path(self.root) / IN_PACKAGE).is_file():
            # An sdist already carries the copy, in the package tree, where the
            # normal file walk picks it up when building the wheel from it
            return
        source = Path(self.root).parent / "features.toml"
        if not source.is_file():
            raise FileNotFoundError(f"Cannot bundle the feature registry: no {source}")
        target = IN_PACKAGE if self.target_name == "sdist" else IN_PACKAGE.relative_to("src")
        build_data["force_include"][str(source)] = str(target)
