"""Bundle the repo-root features.toml into the bestie_template package.

The registry's single source of truth is ../features.toml (shared with the
Julia package). This hook copies it into the branding package for every
non-editable build path: wheels built straight from a repository checkout
(pip install ./python, git+...#subdirectory=python), sdists, and wheels
built from an sdist (where the sdist already carries the copy inside the
package tree). Editable installs skip it — the runtime falls back to the
repo-root file (see bestie_template.bundled_registry_path).
"""

from pathlib import Path

from hatchling.builders.hooks.plugin.interface import BuildHookInterface

REGISTRY_FILENAME = "features.toml"
PACKAGE_RELATIVE = Path("src") / "bestie_template" / REGISTRY_FILENAME


class BundleRegistryHook(BuildHookInterface):
    def initialize(self, version: str, build_data: dict) -> None:
        if version == "editable":
            return
        in_package = Path(self.root) / PACKAGE_RELATIVE
        if in_package.is_file():
            # Building from an sdist: the copy is already inside the package
            # tree and gets included through the normal package file walk.
            return
        repo_copy = Path(self.root).parent / REGISTRY_FILENAME
        if not repo_copy.is_file():
            raise FileNotFoundError(
                f"{REGISTRY_FILENAME} not found at {repo_copy} nor {in_package}; "
                "cannot bundle the feature registry"
            )
        destination = (
            str(PACKAGE_RELATIVE)
            if self.target_name == "sdist"
            else f"bestie_template/{REGISTRY_FILENAME}"
        )
        build_data["force_include"][str(repo_copy)] = destination
