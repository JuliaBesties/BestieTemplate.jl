# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

<!-- markdownlint-disable MD024 -->

## [Unreleased]

## [0.2.1] - 2023-10-02

### Added

- asciinema link in the README

### Fixed

- Text and typos on contribuing and developer

## [0.2.0] - 2023-09-24

### Changed

- First Julia release

## [0.1.9] - 2023-09-24

### Fixed

- Remove `_exclude` section from `copier.yml`

## [0.1.8] - 2023-09-24

### Added

- Should be installable as a Julia package now
- Use PythonCall to run copier directly from the Julia package

### Changed

- Move template to subdirectory

### Fixed

- Allow failure in nightly Julia Test.yml workflow

## [0.1.7] - 2023-09-22

### Changed

- Rename Compliance to Copier in various places (including this CHANGELOG)

## [0.1.6] - 2023-09-22

### Added

- Use pre-commit to prevent adding .rej files and ongoing merge conflicts
- Add configuration file for markdown link checker and ignore @ref

### Changed

- Only ignore Project.toml, not all toml
- Change markdown-lint to fix version

## [0.1.5] - 2023-09-22

### Fixed

- Properly fix copier update when there are conflicts

## [0.1.4] - 2023-09-22

### Fixed

- Fix copier update when there are conflicts

## [0.1.3] - 2023-09-21

### Added

- Run pre-commit in the Copier workflow to commit the formatters change as well

### Changed

- Add a basic structure for the copy's CITATION.cff

## [0.1.2] - 2023-09-16

### Added

- Zenodo DOI
- Instruction to add a Zenodo DOI
- Badge on README

### Changed

- Documenter compat is 1
- Remove keywords strict and linkcheck from docs/make.jl

### Fixed

- File docs/make.jl should not be skipped

## [0.1.1] - 2023-09-15

### Added

- Add CITATION.cff

### Fixed

- Exclude docs/assets/logo.png

## [0.1.0] - 2023-09-12

- Initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
<!-- markdown-link-check-disable -->
[unreleased]: https://github.com/abelsiqueira/COPIERTemplate.jl/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.2.1
[0.2.0]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.2.0
[0.1.9]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.9
[0.1.8]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.8
[0.1.7]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.7
[0.1.6]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.6
[0.1.5]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.5
[0.1.4]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.4
[0.1.3]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.3
[0.1.2]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.2
[0.1.1]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.1
[0.1.0]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.0
