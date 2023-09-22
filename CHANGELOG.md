# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

<!-- markdownlint-disable MD024 -->

## [Unreleased]

### Added

- Use pre-commit to prevent adding .rej files and ongoing merge conflicts

## [0.1.5] - 2023-09-22

### Fixed

- Properly fix compliance when there are conflicts

## [0.1.4] - 2023-09-22

### Fixed

- Fix compliance when there are conflicts

## [0.1.3] - 2023-09-21

### Added

- Run pre-commit in the compliance workflow to commit the formatters change as well

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
[unreleased]: https://github.com/abelsiqueira/COPIERTemplate.jl/compare/v0.1.5...HEAD
[0.1.5]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.5
[0.1.4]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.4
[0.1.3]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.3
[0.1.2]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.2
[0.1.1]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.1
[0.1.0]: https://github.com/abelsiqueira/COPIERTemplate.jl/releases/tag/v0.1.0
