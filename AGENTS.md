# AGENTS.md

Guidance for AI agents working in this repository.

This file holds the **agent-precise** facts: exact file paths, merge orders, and command recipes. For the *why* and the human contributor workflow (fork/clone, releases, building docs), see `docs/src/91-developer.md` — don't duplicate it here.

## Architecture

Julia wrapper around the Python [Copier](https://copier.readthedocs.io) template engine, for generating and updating Julia package templates.

**Source (`src/`)**

- `BestieTemplate.jl`: main module
- `api.jl`: core API (`generate`, `apply`, `update`)
- `friendly.jl`: user-facing helpers, including `add_feature`
- `Copier.jl`: Python integration via PythonCall
- `guess.jl`: auto-detect configuration from an existing repo
- `utils.jl`: utilities
- `debug/`: template testing/debugging (`Debug.jl`, `Data.jl`, `helper.jl`)

**Configuration** — `copier.yml` is the entry point; modular question files live in `copier/`: `constants.yml`, `essential.yml`, `strategy.yml`, `ci.yml`, `code-quality.yml`, `community.yml`.

**Template (`template/`)** — Jinja2 files for generated packages.

**Python package (`python/`)** — `bestie-template`, a port of `add_feature`/`list_features` that needs no Julia (experimental; published to PyPI as `bestie-template`, see issue #617). It reads the same repo-root `features.toml`, so a new feature needs no Python code — only the name added to `test_feature_names` in `python/tests/test_features.py`, which pins the feature set as a drift guard.

- Conditional file/dir inclusion via the filename: `{% if Condition %}filename{% endif %}.jinja`
- Variable substitution in content: `{{ VariableName }}`

## Development commands

- **Test (Pkg)**: `julia --project=. -e "using Pkg; Pkg.test()"`
- **Test (Python)**: `cd python && uv sync && uv run pytest` (skip the real copier runs with `-m "not integration"`)
- **Test (CLI runner)**: `julia --project=test test/runtests.jl`
- **Filtered**: `julia --project=test test/runtests.jl --tags fast --exclude slow` (also `--file`, `--name`, `--list-tags`, `--help`)
- **Lint**: `pre-commit run -a`
- **Docs**: `julia --project=docs -e "using LiveServer; servedocs()"`

When iterating, filter to the relevant files/tags rather than running the full suite. Tag taxonomy and test-data conventions are documented in `docs/src/91-developer.md` ("Test organization and conventions").

Only when running pre-commit on `main`: the `no-commit-to-branch` hook fails and `fail_fast: true` aborts all later hooks, so the lint checks silently don't run. Prefix with `SKIP` to run the real checks: `SKIP=no-commit-to-branch pre-commit run --files <changed files>`. On any other branch, run pre-commit plainly — no `SKIP`.

### Testing via julia-mcp

When julia-mcp is available, prefer it over the CLI — the Julia session stays alive between calls, avoiding recompilation. Use `<full path>/test` as `env_path`, load `TestItemRunner` once with `using TestItemRunner`, then run filtered tests:

- By filename: `@run_package_tests verbose=false filter=ti->contains(ti.filename, "bad-usage")`
- By tags (all must match): `@run_package_tests verbose=false filter=ti->all(t in ti.tags for t in [:fast, :unit])`
- Exclude tags: `@run_package_tests verbose=false filter=ti->!any(t in ti.tags for t in [:slow])`
- By test name: `@run_package_tests verbose=false filter=ti->contains(ti.name, "error")`
- Combined: `@run_package_tests verbose=false filter=ti->(:fast in ti.tags && !(:slow in ti.tags))`

## Adding a new `add_feature(:feature)`

Each feature is defined by an entry in `features.toml` at the repo root (single source of truth, also intended for non-Julia interfaces; field semantics are documented in the registry header comment):

```toml
[features.my_feature]
description = "Adds `path/to/output/file.ext` ..."  # user-facing; the add_feature docstring list is generated from it
forced_data = { MyFlag = true }               # always applied, highest priority
included_files = ["path/to/output/file.ext"]  # only these files are written by copier
optional_files = { SomeFlag = ["config.toml"] }  # optional; written only when SomeFlag and missing
required_fields = ["RequiredField"]           # must be resolvable or errors
requires_answers = false                      # true = .copier-answers.yml must exist
```

Aliases are their own entry with a single key: `alias_of = "my_feature"`. Do not edit the feature list in the `add_feature` docstring — it is generated from the TOML at load time (`_features_docstring` in `src/friendly.jl`).

Data merge order (later wins): answers file → guessed from repo → explicit `data` arg → `forced_data`. Guessing (`src/guess.jl`) only covers facts readable off the package — `PackageName`, `PackageUUID`, `Authors`, `JuliaMinVersion`, `PackageOwner`, `JuliaIndentation` — so `required_fields` outside that set must come from the answers file or the caller. The Python port does not guess at all.

`requires_answers = true` is for features whose `required_fields` fall outside what guessing covers, where a default would silently render a wrong file (`lint_action`: `AddPrecommit` and `AddLychee` say which tools the package uses, `Lint.yml` runs a job for each, and guessing doesn't cover them — the Python CLI never guesses at all). When that set of fields is small and closed, also add a `<feature>_explicit` entry that lists them in `required_fields` with `requires_answers = false`, so packages without `.copier-answers.yml` can use the feature by stating its intent. Skip the variant when the output depends on many answers. See the developer docs for the full rationale.

`optional_files` maps a boolean field to files the feature's own output needs when that field is true (`lint_action_explicit`'s `link-checker` job reads `.lychee.toml`). They are written only when missing, so an existing file is kept and two features may declare the same path without conflict. Declare what your output references, not what you "own". Test the flags with `_is_true`, never directly: a CLI `-d Flag=false` arrives as the string `"false"`, which is truthy in both languages.

Before writing tests, verify the entry matches the template: the `included_files` are gated on the `forced_data` flag (e.g. `{% if MyFlag %}filename{% endif %}.jinja`), and the `required_fields` really are required. Ask the user if anything is ambiguous.

Both the `AddFeatureHelpers` snippet and the tests live in `test/test-add-feature.jl`. Which helpers apply depends on `requires_answers` and `required_fields`:

- `_test_happy_path`: feature generates expected file(s)
- `_test_works_without_answers_by_guessing` (if `requires_answers = false`): works when data is guessable
- `_test_works_on_empty_folder` (if no `required_fields` and `requires_answers = false`): works on a minimal src/test directory
- `_test_errors_without_data`: errors when required data is missing
- `_test_explicit_data_override` (for features with `required_fields`): `data` arg beats guessed/answers values

## Adding a new Copier question

### Step 1 — Define the question in a `copier/*.yml` file

Pick the file by domain: `constants.yml` (computed, never shown — `when: false`), `essential.yml` (required, asked before strategy), `strategy.yml` (strategy selection/derived vars), `code-quality.yml`, `community.yml`, `ci.yml`.

```yaml
AddMyFeature:
  when: "{{ WhenForLight }}"         # WhenFor{Light,Moderate,Robust,Advanced}
  type: bool                         # bool, str, or int
  default: "{{ DefaultForLight }}"   # DefaultFor* matches the strategy level
  help: Add my feature (Brief description shown in the interactive prompt)
  description: |                     # Longer text, auto-included in the Questions docs page
    What this feature does and why you'd want it.

    Strategy: Light
```

The `description` **must** end with a `Strategy: <Level>` line for every question outside `essential.yml`/`strategy.yml` — `docs/src/30-questions.md` parses the yml files and errors the docs build without it.

Optional fields when needed: `choices:` (map of `"Display name": value`, str type — see `TestingStrategy`, `License`), `validator:` (Jinja2 returning empty string if valid — see `PackageName`, `JuliaIndentation`), `placeholder:` (see `Authors`). Copy the closest existing question rather than inventing a shape.

Naming: **PascalCase**; `Add*` for boolean toggles (`AddDocs`, `AddPrecommit`); `Check*`/`Run*` for behaviors (`CheckExplicitImports`, `RunJuliaNightlyOnCI`); no prefix for basic info (`PackageName`, `License`).

Dependent questions key their `when` off the parent: `when: "{{ AddMyFeature and WhenForModerate }}"`.

### Step 2 — Use the question in template files

```text
template/{% if AddMyFeature %}path/to/file.ext{% endif %}.jinja   # conditional file/dir
```

```jinja
{% if AddMyFeature -%}
Content only present when the feature is enabled.
{% endif -%}
```

- **Aggregate folder flags** (in `copier/ci.yml`): if the new question gates a file under `template/.../workflows/`, add it to the `AddWorkflowsFolder` default expression; if it gates any other file under `template/.../.github/`, check `AddDotGitHubFolder`. These expressions must list exactly the flags that create files in those folders — flags that only alter the *content* of other files do not belong there.
- **`_skip_if_exists`** (in `copier.yml`): if the generated file is meant to be user-edited after generation (CHANGELOG.md, LICENSE, CITATION.cff), add it here so `copier update` won't overwrite user changes.
- **Cross-file references**: grep template files for related content that should become conditional on the new question (e.g. `AddChangelog` added a release section to `91-developer.md.jinja`).

### Step 3 — Add test data (`src/debug/Data.jl`)

Add the default to the lowest strategy level where it becomes relevant (levels merge upward):

```julia
light = merge(tiny, Dict("AddMyFeature" => true, #= ... =#))
```

### Step 4 — Add random test value (`test/utils.jl`)

Only for non-trivial types; bool/str-without-choices use existing fallbacks.

```julia
_random(::Val{:MyChoiceQuestion}, value) = rand(["option1", "option2", "option3"])
```

### Step 5 — Add test coverage

Question-level tests go in a new `test/test-<feature>.jl`. At minimum verify: file present when enabled, absent when disabled, content substitution correct (key strings, values like `PackageOwner`), and any conditional blocks in other templates present/absent as expected. Add `add_feature` coverage per the section above.

### Strategy system reference

- **StrategyLevel**: 0=Tiny, 1=Light, 2=Moderate, 3=Robust
- `DefaultFor{Light,Moderate,Robust,Advanced}`: `true` if `StrategyLevel >=` that level's threshold
- `WhenFor{Light,Moderate,Robust,Advanced}`: whether the question is shown, based on the strategy level and the user's `StrategyConfirmIncluded`/`StrategyReviewExcluded` choices
- Questions default to their `DefaultFor*` value without being asked, unless the user opts to confirm/review

## Breaking changes to the update test

The test "Test updating from main to HEAD vs generate in HEAD" (`test/test-bestie-specific-api.jl`) checks that existing users can update cleanly. Some changes unavoidably break it (e.g. an LTS bump that `Project.toml`'s `_skip_if_exists` prevents updating). To skip it: set `ENV["BESTIE_SKIP_UPDATE_TEST"] = "yes"` locally, include `BESTIE_SKIP_UPDATE_TEST` anywhere in the commit message, and add a breaking notice to the CHANGELOG. Full deprecation procedure for removing a question is in `docs/src/91-developer.md`.

## CHANGELOG

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). New entries go under `## [Unreleased]`.

- Sections: `### Added`, `### Changed`, `### Fixed`, `### Removed`, `### Deprecated`
- Each entry is a `-` bullet, optionally ending with `(#issue_number)`
- Concise, user-facing language (what changed for the user, not implementation details)
- Reference-style links at the bottom: `[unreleased]` compare link and `[version]` release links

## Dependencies

Requires the Python Copier backend, managed via `CondaPkg.toml`. Tests use a local conda environment in `test/conda-env/` to avoid re-downloading.
