# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

BREAKING NOTICE:

- The pre-commit autoupdate CI is no longer part of the `Precommit` question, and defaults to `false`. To keep the workflow, add `"AddPrecommitUpdateCI" => true` to your data argument, or ask to "Review all excluded items" in the interactive mode.
- The default markdownlint configuration now accepts duplicate headers when the headers are on different levels. This improves the experience of some CHANGELOG formats. To revert this locally change `siblings_only` to false in `.markdownlint.json` (i.e., `"MD024": { "siblings_only": false }`). In that case, CHANGELOG will fail to pass this rule, but you can manually add `<!-- markdownlint-disable MD024 -->` in the beginning of the file to skip it.

### Added

- Automatic list of docs pages should now include subsections from folders (#536)
- New question: `AddPrecommitUpdateCI` to make the pre-commit autoupdate CI optional (#503)

### Changed

- The pre-commit autoupdate CI is no longer part of the `Precommit` question, and defaults to `false` (advanced) (#503)
- The default markdownlint configuration (in `.markdownlist.json`) now has `MD024.siblings_only = true` (#505)

## [0.16.2] - 2025-05-31

### Fixed

- Error `key "_commit" not found` (#534)

## [0.16.1] - 2025-05-31

### Fixed

- When generating from a local copy, change permissions of the resulting project to prevent it being read-only (#532).

## [0.16.0] - 2025-05-30

BREAKING NOTICE:

- This version had a major refactor of the strategies. You will have to reevaluate which strategy to follow in an update. Here is a simple guide:
  - `Tiny`: Only used for bare-bones package;
  - `Light`: Closest to the most common Julia experience (now the default);
  - `Moderate`: Adds best practices, but keeps it reasonable for solo devs;
  - `Robust`: Adds best practices for larger packages and communities.

### Added

- New question: `AddCitationCFF` to make the CITATION.CFF optional.
- New question: `AddDependabot` to make `.github/dependabot.yml` optional.
- New question: `AddGitHubPRTemplate` to make `.github/PULL_REQUEST_TEMPLATE.md` optional.
- New question: `AddLintCI` to make `.github/workflows/Lint.yml` optional.
- New question: `AddDocs` to make the `docs` folder optional.
- New question: `AddDocsCI` to make `.github/workflows/Docs.yml` optional.
- New question: `AddCompatHelperCI` to make `.github/workflows/CompatHelper.yml` optional.
- New question: `AddTagBotCI` to make `.github/workflows/TagBot.yml` optional.
- New question: `AddTestCI` to make `.github/workflows/`'s `Test.yml`, `TestOnPRs`, and `ReusableTest.yml` optional.
- New question: `AddLychee` to make `.lychee.toml` optional.
- New question: `AddFormatterAndLinterConfigFiles` to include configuration files for linters and formatters.
- New function: `new_pkg_quick`, for a non-interactive way to create a new package.
- Functions `generate` and `apply` have new methods accepting `:local` and `:online`.

### Changed

- Reworks the strategy system to use `StrategyLevel`.
  - Introduces the levels Minimalistic, Light, Moderate, and Robust.
- Rename `Minimalistic` to `Tiny`.
- Badges on the template's README.md are better separated according to the options.

## [0.15.0] - 2025-02-21

BREAKING NOTICE:

- Previously deprecated questions for `AuthorName`, `AuthorEmail`, and `Indentation` are now removed.

### Added

- Pre-commit hook `yamlfmt` added.

### Removed

- `AuthorName` and `AuthorEmail` were deprecated in 0.10.0 and are now removed
- `Indentation` was deprecated in 0.12.0 and is now removed
- Pre-commit hook `prettier` was removed due to mirrors-prettier being unsupported.

## [0.14.1] - 2024-11-12

### Fixed

- Fix method overwriting error of `dbg_generate` in precompilation and enable more flexible calling signatures (#514)

## [0.14.0] - 2024-10-29

BREAKING NOTICE:

- The link-checker now uses lychee version 2, which might lead to failures. See <https://github.com/JuliaBesties/BestieTemplate.jl/pull/495> for the release notes.

### Added

- Create a new strategy to allow users to install all recommended and get asked additional questions.
- New questions: `CheckExplicitImports` and `ExplicitImportsChecklist`, to determine whether to check for using vs import and public API usage, and which checks to perform (#349)

### Changed

- Update action version
  - lycheeverse/lychee-action 1 -> 2
- Update applied Bestie's version right before releasing v0.14.0

## [0.13.0] - 2024-10-11

BREAKING NOTICE (MANUAL INTERVENTION REQUIRED):

- The LTS version has changed from 1.6 to 1.10. When updating, if you want to change the value of `JuliaMinVersion` (the minimum version in Project.toml), then:
  - You must change the `.copier-answers.yml` file (before or after running `update`)
  - You must manually change `Project.toml`
  - You might have to manually change `Test.yml` and/or `TestOnPRs.yml` in the folder `.github/workflows`

### Changed

- Change internal LTS version to 1.10. This affects the default value of `JuliaMinVersion` (#486)

### Fixed

- Many trailing white spaces and duplicate empty lines resulting from Jinja variables. Pre-commit succeeds more often for newly generated files with default answers (#445)

## [0.12.0] - 2024-10-08

Breaking notice:

- `Indentation` has been deprecated in favour of `JuliaIndentation`, `MarkdownIndentation` and `ConfigIndentation`.

### Added

- New question: `JuliaIndentation`, which controls the indentation for Julia files (#460)
- New question: `MarkdownIndentation`, which controls the indentation for Markdown files (#460)
- New question: `ConfigIndentation`, which controls the indentation for configuration files (#460)

### Deprecated

- `Indentation` has been deprecated in favour of `JuliaIndentation`, `MarkdownIndentation` and `ConfigIndentation` (#460)

## [0.11.0] - 2024-10-07

### Added

- Add BestieTemplate badge to README (#296)

### Changed

- Move package to JuliaBesties (#318)
- Update pre-commit hook versions
  - markdownlint-cli 0.41.0 -> 0.42.0

## [0.10.1] - 2024-09-10

### Fixed

- The TestGeneratedPkg workflow now runs the latest unreleased version of the pkg (#450)
- The tests of the generated package correctly include the `test-*.jl` files (#452)

## [0.10.0] - 2024-09-10

Breaking notice:

- `AuthorName` and `AuthorEmail` have been deprecated. Expect them to be removed in the next version. They are replaced by a single question `Authors`, which receives a comma separated list. Additionally, the Code of Conduct used the `AuthorEmail`, and now it has its own question.

### Added

- The keyword argument `quiet` is now used to define verbosity (#379)
- The keyword `guess` in `apply` to control whether guessing answers is desired (#225)
- The minimum Julia version is also guessed now (#225)
- The package owner is also guessed now (#225)
- The indentation is also guessed now (#225)
- New question: `JuliaMinCIVersion`, which defines which Julia version to use in the CI (#400)
- New question: `AutoIncludeTests`, that auto-includes all `test-*.jl` files in `runtests.jl` (#261)
- New question: `CodeOfConductContact`, the contact person/entity for the `CODE_OF_CONDUCT.md` file (#426)
- New question: `LicenseCopyrightHolders`, the copyright holders listed in the LICENSE (#427)
- New question: `Authors`, a comma separated list of authors. (#118)

### Changed

- Update pre-commit hook versions
  - JuliaFormatter 1.0.58 -> 1.0.60
- Default Indentation changed from 2 to 4 (#403)
- Change lychee configuration to a hidden file `.lychee.toml`

### Deprecated

- `AuthorName` and `AuthorEmail` have been deprecated in favour of `Authors`.

## [0.9.1] - 2024-07-24

### Changed

- Update pre-commit hook versions
  - JuliaFormatter 1.0.56 -> 1.0.58
- Validate package name to enforce capital first letter and letters and numbers (#373)

## [0.9.0] - 2024-07-13

### Changed

- Default `.JuliaFormatter` now includes only minimal configuration that matches `.editorconfig` (#358)

## [0.8.0] - 2024-07-08

### Added

- New question: AddContributionDocs to decide whether to add 90-contributing.md and 91-developer.md (#313)

### Changed

- (breaking change) GitHub PR template is now part of the minimal options (#308)
- (breaking change) TestOnPRs.yml is now part of the minimal options (#312)
- (breaking change) 90-contributing.md and 91-developer.md have moved from minimal to recommended. If you use the minimal option, then these files will be removed (#313)
- (breaking change) `generate` does not work on existing folders anymore. The function `apply` was created to handle that case (#301)

### Removed

- (breaking change) Question SimplifiedPRTest was removed and the behaviour now is as if it were selected as true (#312)

## [0.7.2] - 2024-07-07

### Added

- Add example to the generated package src and test (#299)

### Changed

- Fixed typos in the template for README.md (#327)
- Simplify Cirrus CI (PR #332)

### Fixed

- Lint.yml was missing from minimum options (#317)

## [0.7.1] - 2024-07-02

### Changed

- Logo has changed.
- Apply the template version 0.7.0

## [0.7.0] - 2024-06-26

### Changed

- Rename the package from COPIERTemplate.jl to BestieTemplate.jl

## [0.6.1] - 2024-06-21

### Changed

- Small improvements to templates

## [0.6.0] - 2024-06-14

### Changed

- Rename files in docs/src/ 90-developer to 91 and 90-reference to 95 (#273)

## [0.5.4] - 2024-06-11

### Changed

- Indentation is now a required question

## [0.5.3] - 2024-06-10

### Changed

- Update documentation in various places
- Add developer documentation for dealing with the template

### Fixed

- Template had bad double quotes instead of single in the Test.yml workflow

## [0.5.2] - 2024-06-08

### Added

- Update function that calls copier's run_update (#113)
- Safeguard to avoid running generate when you want update (#247)

### Changed

- Improve skip section in README.md and make small corrections in the template

## [0.5.1] - 2024-06-07

### Added

- New question: AddPrecommit to add pre-commit related files (#231)
- New question: AddGitHubTemplates to add issue and PR templates (#233)
- New question: AnswerStrategy to choose between using recommended, minimum, or ask every question (#235)
- New question: AddCopierCI to add Copier.yml (#237)

### Changed

- Issue checklists are now just text (#234)

## [0.5.0] - 2024-06-06

### Added

- New question: SimplifiedPRTest to simplify the testing on Pull Requests (#105)
- New question: AddAllcontributors to add a section and config for <https://allcontributors.org> (#26)
- `copy`, `recopy` and `update` from the copier API (#142)
- When applying to existing projects, read Project.toml to infer a few values (#116)
- Automatically determines the `PackageName` from the destination folder (#151)

### Changed

- Adds `data` positional argument to `generate` (#142)
- An internal module `Copier` was created with the wrapper functions
- Use lychee for link-checker instead of markdown-link-checker (#160)

### Removed

- The `generate_missing_uuid` argument was removed, since it can be generated via Jinja (#189)

## [0.4.0] - 2024-05-31

### Added

- Pre-commit update workflow (#91)

### Changed

- Signature of generate now accepts source path, which defaults to the URL (#174)

## [0.3.2] - 2024-05-30

### Added

- More reader-friendly README (#144)
- Add author names to licenses (#145)
- Consistent caching in GitHub workflows (#53)

## [0.3.1] - 2024-05-23

### Added

- Dependabot (#52)

## [0.3.0] - 2024-05-17

### Added

- Indentation option (#44)
- CODE_OF_CONDUCT (#25)
- Issue and Pull Request templates (#33)
- AskAdvancedQuestions question to allow stopping early (#67)

### Changed

- Update Cirrus CI image_family (#31)
- Prefix some doc files with a number and generate the pages programmatically (#32)
- Reestructure and improve the documentation (#77)

### Fixed

- Coverage now checks main branch (#65)

## [0.2.5] - 2024-02-23

### Fixed

- nightly key was duplicated (#49)

## [0.2.4] - 2023-12-21

### Fixed

- pipx link changed

## [0.2.3] - 2023-10-31

### Changed

- Add `workflow_dispatch` to Test.yml

### Fixed

- Windows support

## [0.2.2] - 2023-10-02

### Fixed

- Don't skip contributing.md and developer.md on updates

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

[unreleased]: https://github.com/JuliaBesties/BestieTemplate.jl/compare/v0.16.2...HEAD
[0.16.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.16.2
[0.16.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.16.1
[0.16.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.16.0
[0.15.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.15.0
[0.14.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.14.1
[0.14.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.14.0
[0.13.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.13.0
[0.12.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.12.0
[0.11.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.11.0
[0.10.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.10.1
[0.10.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.10.0
[0.9.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.9.1
[0.9.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.9.0
[0.8.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.8.0
[0.7.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.7.2
[0.7.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.7.1
[0.7.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.7.0
[0.6.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.6.1
[0.6.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.6.0
[0.5.4]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.5.4
[0.5.3]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.5.3
[0.5.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.5.2
[0.5.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.5.1
[0.5.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.5.0
[0.4.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.4.0
[0.3.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.3.2
[0.3.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.3.1
[0.3.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.3.0
[0.2.5]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.5
[0.2.4]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.4
[0.2.3]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.3
[0.2.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.2
[0.2.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.1
[0.2.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.2.0
[0.1.9]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.9
[0.1.8]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.8
[0.1.7]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.7
[0.1.6]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.6
[0.1.5]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.5
[0.1.4]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.4
[0.1.3]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.3
[0.1.2]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.2
[0.1.1]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.1
[0.1.0]: https://github.com/JuliaBesties/BestieTemplate.jl/releases/tag/v0.1.0
