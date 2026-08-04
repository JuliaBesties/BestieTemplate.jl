# [Developer documentation](@id dev_docs)

!!! note "Contributing guidelines"
    If you haven't, please read the [Contributing guidelines](90-contributing.md) first.

If you want to make contributions to this package that involves code, then this guide is for you.

## First time clone

!!! tip "If you have writing rights"
    If you have writing rights, you don't have to fork. Instead, simply clone and skip ahead. Whenever **upstream** is mentioned, use **origin** instead.

If this is the first time you work with this repository, follow the instructions below to clone the repository.

1. Fork this repo
2. Clone your repo (this will create a `git remote` called `origin`)
3. Add this repo as a remote:

   ```bash
   git remote add upstream https://github.com/JuliaBesties/BestieTemplate.jl
   ```

This will ensure that you have two remotes in your git: `origin` and `upstream`.
You will create branches and push to `origin`, and you will fetch and update your local `main` branch from `upstream`.

## Linting and formatting

Install a plugin on your editor to use [EditorConfig](https://editorconfig.org).
This will ensure that your editor is configured with important formatting settings.

We use [https://pre-commit.com](https://pre-commit.com) to run the linters and formatters.
In particular, the Julia code is formatted using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl), so please install it globally first:

```julia-repl
julia> # Press ]
pkg> activate
pkg> add JuliaFormatter
```

To install `pre-commit`, we recommend using [pipx](https://pipx.pypa.io) as follows:

```bash
# Install pipx following the link
pipx install pre-commit
```

With `pre-commit` installed, activate it as a pre-commit hook:

```bash
pre-commit install
```

To run the linting and formatting manually, enter the command below:

```bash
pre-commit run -a
```

**Now, you can only commit if all the pre-commit tests pass**.

### Link checking locally

We use `lychee` for link checking in CI. You can run it locally to avoid waiting for CI. First, [install lychee](https://github.com/lycheeverse/lychee?tab=readme-ov-file#installation), then run against the repository root using the project config:

```bash
lychee --no-progress --config lychee.toml .
```

## Testing

As with most Julia packages, you can just open Julia in the repository folder, activate the environment, and run `test`:

```julia-repl
julia> # press ]
pkg> activate .
pkg> test
```

### CLI Test Runner

The repository includes a CLI test runner for more flexible testing with TestItems:

```bash
# Run all tests
julia --project=test test/runtests.jl

# Run with verbose output
julia --project=test test/runtests.jl --verbose

# Filter tests by tags (run only fast tests)
julia --project=test test/runtests.jl --tags fast

# Exclude slow tests
julia --project=test test/runtests.jl --exclude slow

# Run tests from specific files
julia --project=test test/runtests.jl --file test-corner-cases.jl

# Run tests matching name pattern
julia --project=test test/runtests.jl --name "some test"

# Show available tags
julia --project=test test/runtests.jl --list-tags

# Show help
julia --project=test test/runtests.jl --help
```

### julia-mcp (Testing with AI agents)

[julia-mcp](https://github.com/aplavin/julia-mcp) provides a persistent Julia REPL session as an MCP server.
When working with an AI agent (e.g., Claude Code), configure it to use julia-mcp so that the agent can run tests directly without Julia startup and recompilation overhead on every call.

Install and configure it following the instructions in the [julia-mcp repository](https://github.com/aplavin/julia-mcp). Once set up, the agent can load `TestItemRunner` once and then run filtered tests iteratively, much faster than spawning a new Julia process each time.

### Test organization and conventions

We use [TestItems](https://www.julia-vscode.org/docs/stable/userguide/testitems/) for testing (self-promotion: [TestItems - Modern Julia testing; watching and rerunning; AI agent usage with julia-mcp](https://youtu.be/vr2P9t-EnuU)).
A few conventions specific to this repository:

- We use `test-<descriptive-name>.jl` for the file names, and that's the main categorization level.
- Prefer multiple `@testitem`s instead of a deep loop, if it makes the code more readable.
- There are commonly used `@testsnippet`s and `@testmodule`s in `test/utils.jl`, and more specific `@testsnippet`s go inside their own file.
- Tags are not heavily used, but it is still useful to have some of them. The ones that matter most are:
  - *Test type*: `:unit`, `:integration`, `:validation`
  - *Speed*: `:fast`, `:slow`

#### Test data for the strategies

Shared fixtures live in `src/debug/Data.jl`, which defines the answer data for each strategy level (`tiny`, `light`, `moderate`, `robust`). Each level merges from the previous, so a new question's default value goes at the lowest level where it becomes relevant.

For questions with non-trivial types, add a `_random(::Val{:QuestionName}, value)` method in `test/utils.jl` so randomized tests can pick a valid value. Boolean and string questions without `choices` are covered by the existing fallbacks.

### Adding a new `add_feature(:feature)`

`add_feature(:feature, path)` applies a specific subset of template files without re-running the full interactive setup. Each feature is defined by an entry in the `features.toml` registry at the repository root, which is the single source of truth (also intended for non-Julia interfaces):

```toml
[features.my_feature]
description = "Adds `path/to/output/file.ext` ..."  # user-facing; the add_feature docstring list is generated from it
forced_data = { MyFlag = true }               # always applied, highest priority
included_files = ["path/to/output/file.ext"]  # only these files are written by copier
required_fields = ["RequiredField"]           # must be resolvable or errors
requires_answers = false                      # true = .copier-answers.yml must exist
```

Aliases are entries with a single `alias_of = "other_feature"` key.

**Data merge order** (later wins): answers file → guessed from repo → explicit `data` arg → `forced_data`.

If the `required_fields` can be guessed (e.g., by `_read_data_from_existing_path` in `src/guess.jl`, or if they are present in a `.copier-answers.yml` file), then the experience is smooth.
Otherwise, they need to be given explicitly, e.g., via the `data` argument in Julia, or `-d` flags in the Python CLI.

#### [When a feature depends on user choices: the `_explicit` convention](@id explicit_features)

`requires_answers = true` was introduced to deal with features that could not be guessed from a repo.
Essentially, these are features that require more than the minimum information in an existing package.
`lint_action` is one case: `AddPrecommit` and `AddLychee` record whether the package uses pre-commit and the Lychee link checker (`copier/code-quality.yml`), and `Lint.yml` runs a job for each tool that is enabled.
These answers are not automatically guessed from the package - even if they could be in the future - and via the Python CLI they can't be guessed.
If forcing the template defaults, these answers would give a wrong result. In this case, for example, the `Lint.yml` action would be created but it would be essentially empty, becoming useless.
The flag prevents that by insisting the package already recorded its answers.

That is the right guard, but it locks the feature to packages that already use the template. When the set of choices is small and closed, we should try to ship a second entry named `<feature>_explicit` that lists these answers in `required_fields` with `requires_answers = false`:

```toml
[features.lint_action_explicit]
required_fields = ["AddPrecommit", "AddLychee"]
requires_answers = false
```

Any package can then use it by stating its intent (`-d AddPrecommit=true -d AddLychee=false`), and the "cannot determine required fields" error names exactly what to pass. Packages that *do* have an answers file keep working, since the fields resolve from it.

Add the `_explicit` variant when the dependency set is small, enumerable, and meaningful to a user. Keep `requires_answers = true` alone when the output depends on many answers, or on ones a user cannot reasonably be asked to supply — an explicit variant that needs ten flags is worse than no variant.

**Checklist to add a new feature:**

1. Add a `[features.my_feature]` entry in `features.toml`. If it needs `requires_answers = true`, decide whether an `_explicit` companion is warranted (see [the `_explicit` convention](@ref explicit_features)).
2. Check that the entry matches the template: the `included_files` in `template/` should be gated on the `forced_data` flag (e.g. `{% if MyFlag %}filename{% endif %}.jinja`), and the `required_fields` should be ones the feature genuinely cannot resolve on its own.
3. Add tests in `test/test-add-feature.jl` using the `AddFeatureHelpers` snippet helpers (defined in the same file):
   - `_test_happy_path`: feature generates expected file(s)
   - `_test_works_without_answers_by_guessing` (if `requires_answers = false`): works when data is guessable
   - `_test_works_on_empty_folder` (if no `required_fields` and `requires_answers = false`): works on a minimal src/test directory
   - `_test_errors_without_data`: errors when required data is missing
   - `_test_explicit_data_override` (for features with `required_fields`): verifies `data` arg takes priority
4. Add the feature name to `test_feature_names` in `python/tests/test_features.py` (see [The Python package](@ref python_package)) and run `cd python && uv run pytest`.

### [The Python package (`python/`)](@id python_package)

`python/` holds `bestie-template`, a port of `add_feature` and `list_features` that needs no Julia, plus a `bestie` CLI over them.
It is experimental, and published to PyPI as [`bestie-template`](https://pypi.org/p/bestie-template) (see [Making a new Python release](@ref)).

```bash
cd python
uv sync          # .venv with the package (editable) + dev dependencies
uv run pytest    # unit tests, plus integration tests that run real copier on this checkout
uv run bestie list-features
```

Both implementations read the same repo-root `features.toml`, so a new feature serves both without Python changes.
`test_feature_names` pins the exact feature set on purpose: a registry change that forgets the other side fails there. Since an installed wheel has no repository around it, `hatch_build.py` copies `features.toml` into the package at build time — never add a second copy under `python/` by hand.

Linting and formatting come from the repository-wide pre-commit setup (`ruff`, `ruff-format`; configured in `python/pyproject.toml`), and `.github/workflows/TestPython.yml` runs the suite and builds the wheel on CI.

### Testing local changes to the template

We have created tools to help test and debug changes to the template.
These tools are subject to change without notice, but we will try to keep this section updated.

My normal testing strategy is

#### 1. Go to a temp path

On Linux and OSX you should be able to use `cd $(mktemp -d)`, but you can also use `julia`:

```julia-repl
julia> cd(mktempdir())  # creates a temporary folder and enter it
julia> pwd()            # shows where you are
```

#### 2. `pkg> dev` the Bestie path

Now, in a temporary folder, start Julia if you haven't and do the following:

```julia-repl
julia> # press ]
pkg> dev full/path/to/bestie
pkg> # press backspace
julia> using BestieTemplate
```

#### 3. Use the debug tools

```julia-repl
julia> Dbg = BestieTemplate.Debug
julia> Dbg.Data           # module for the various data examples
julia> Dbg.dbg_generate   # to test generate
julia> Dbg.dbg_apply      # to test apply
```

To check everything available in the Debug module, check the [Debug auto docs](@ref).

The minimum that you need is:

```julia-repl
julia> Dbg.dbg_generate()
```

This will create a new folder inside the current temporary folder with a name like `PkgDebugBestieX`. The `X` is a number automatically increased. It will use the path of the Bestie that you `dev`ed, and it will use some fake data, some defaults, and the "minimum" strategy.

If you want to change the data being used, you can give the keyword argument `data_choice`:

```julia-repl
julia> Dbg.dbg_generate(data_choice = :rec)
```

This will use the "recommended" strategy. Check [`BestieTemplate.Debug.dbg_data`](@ref) to see all options.

Check the full docs and the code for more details on what `dbg_generate` can do.

#### Alternative: use copier directly

You can also use `copier` directly to test the template.
You just have to run copier with the `--vcs-ref HEAD` flag and point to your local clone:

```bash
copier copy --vcs-ref HEAD /path/to/bestie/ pkg
```

Of course, in this case you won't have the pre-filled data, so it isn't the preferred way for longer testing/debugging sessions.

## Working on a new issue

We try to keep a linear history in this repo, so it is important to keep your branches up-to-date.

1. Fetch from the remote and fast-forward your local main

   ```bash
   git fetch upstream
   git switch main
   git merge --ff-only upstream/main
   ```

2. Branch from `main` to address the issue (see below for naming)

   ```bash
   git switch -c 42-add-answer-universe
   ```

3. Push the new local branch to your personal remote repository

   ```bash
   git push -u origin 42-add-answer-universe
   ```

4. Create a pull request to merge your remote branch into the org main.

### Branch naming

- If there is an associated issue, add the issue number.
- If there is no associated issue, **and the changes are small**, add a prefix such as "typo", "hotfix", "small-refactor", according to the type of update.
- If the changes are not small and there is no associated issue, then create the issue first, so we can properly discuss the changes.
- Use dash separated imperative wording related to the issue (e.g., `14-add-tests`, `15-fix-model`, `16-remove-obsolete-files`).

### Commit message

- Use imperative or present tense, for instance: *Add feature* or *Fix bug*.
- Have informative titles.
- When necessary, add a body with details.
- If there are breaking changes, add the information to the commit message.

### AI Coding Assistant Attribution

We use and accepts pull requests with AI coding assistants to help with development, but we expect the committers to understand and be responsible for the code that they introduce.
All commits that receive AI assistance should be signed off with:

```plaintextt
Co-authored-by: MODEL NAME (FULL MODEL VERSION) <EMAIL>
```

For example:

```plaintextt
Co-authored-by: Claude Code (claude-sonnet-4-20250514) <noreply@anthropic.com>
```

### Before creating a pull request

!!! tip "Atomic git commits"
    Try to create "atomic git commits" (recommended reading: [The Utopic Git History](https://blog.esciencecenter.nl/the-utopic-git-history-d44b81c09593)).

- Make sure the tests pass.
- Make sure the pre-commit tests pass.
- Fetch any `main` updates from upstream and rebase your branch, if necessary:

  ```bash
  git fetch upstream
  git rebase upstream/main BRANCH_NAME
  ```

- Then you can open a pull request and work with the reviewer to address any issues.

## Building and viewing the documentation locally

Following the latest suggestions, we recommend using `LiveServer` to build the documentation.
Here is how you do it:

1. Run `julia --project=docs` to open Julia in the environment of the docs.
1. If this is the first time building the docs
   1. Press `]` to enter `pkg` mode
   1. Run `pkg> dev .` to use the development version of your package
   1. Press backspace to leave `pkg` mode
1. Run `julia> using LiveServer`
1. Run `julia> servedocs()`

## Making a new release

To create a new release, you can follow these simple steps:

- Create a branch `release-x.y.z`
- Update `version` in `Project.toml`
- Update the `CHANGELOG.md`:
  - Rename the section "Unreleased" to "[x.y.z] - yyyy-mm-dd" (i.e., version under brackets, dash, and date in ISO format)
  - Add a new section on top of it named "Unreleased"
  - Add a new link in the bottom for version "x.y.z"
  - Change the "[unreleased]" link to use the latest version - end of line, `vx.y.z ... HEAD`.
- Create a commit "Release vx.y.z", push, create a PR, wait for it to pass, merge the PR.
- Go back to main screen and click on the latest commit (link: <https://github.com/JuliaBesties/BestieTemplate.jl/commit/main>)
- At the bottom, write `@JuliaRegistrator register`

After that, you only need to wait and verify:

- Wait for the bot to comment (should take < 1m) with a link to a PR to the registry
- Follow the link and wait for a comment on the auto-merge
- The comment should said all is well and auto-merge should occur shortly
- After the merge happens, TagBot will trigger and create a new GitHub tag. Check on <https://github.com/JuliaBesties/BestieTemplate.jl/releases>
- After the release is create, a "docs" GitHub action will start for the tag.
- After it passes, a deploy action will run.
- After that runs, the [stable docs](https://JuliaBesties.github.io/BestieTemplate.jl/stable) should be updated. Check them and look for the version number.

## Making a new Python release

The `bestie-template` Python package (see [The Python package (`python/`)](@ref python_package)) is released independently of the Julia package, using `py-vx.y.z` tags.
Only release it when something under `python/` changes, or when a feature is added, renamed, or removed in `features.toml`.

Release BestieTemplate.jl first and wait for the tag, because the wheel bakes in `features.toml` at build time but resolves the template's latest tag at run time. Otherwise the wheel can advertise a feature that the latest tag does not have, and `bestie add-feature` fails.

- Create a branch `python-release-x.y.z`
- Update `version` in `python/pyproject.toml`, then run `cd python && uv lock`
- Add a `CHANGELOG.md` entry under "Unreleased", without renaming the section (the changelog tracks the whole repository)
- Create a commit "Release py-vx.y.z", push, create a PR, wait for it to pass, merge the PR.
- Tag the merged commit on `main` with `py-vx.y.z` and push the tag. Tag `main` and not the branch: PyPI uploads are immutable, and a squash-merged branch commit is not in the history of `main`.

After that, you only need to wait and verify:

- The tag triggers the `PublishPython` workflow, which checks the tag against the version, builds and smoke-tests the wheel, then waits on the `pypi` environment. Approve the deployment if it requires reviewers.
- Check <https://pypi.org/p/bestie-template>, then verify with `uvx --from bestie-template==x.y.z bestie --version`.

## Additions to the templates

!!! info "Suggestions are not here"
    This section is aimed at the developer working on a new question, if you have any new idea or think the template needs to be updated or fixed, please search our [issues](https://github.com/JuliaBesties/BestieTemplate.jl/issues) and if there isn't anything relevant, open a new issue.

### [The strategy system](@id strategy_system)

Before writing a question, you need to know how the strategy system decides whether it is asked and what it defaults to.
It is defined in `copier/strategy.yml`:

- **`StrategyLevel`** is the user's answer: `0` = Tiny, `1` = Light, `2` = Moderate, `3` = Robust.
- **`DefaultFor{Light,Moderate,Robust,Advanced}`** are hidden (`when: false`) booleans that are `true` when `StrategyLevel` reaches that level. `DefaultForAdvanced` is always `false`; advanced questions are never enabled by a strategy, only by the user.
- **`WhenFor{Light,Moderate,Robust,Advanced}`** are hidden booleans deciding whether the question is *shown*. A question that the strategy includes is only asked if the user answered `StrategyConfirmIncluded`; one that the strategy excludes is only asked if the user answered `StrategyReviewExcluded`.

So a question is placed in a strategy level simply by picking the matching `WhenFor*`/`DefaultFor*` pair, and users who accept the strategy are never prompted.

### Creating a new question

Questions live in the modular files under `copier/`, which `copier.yml` pulls in with `!include`:

| File | Contents |
| :-- | :-- |
| `constants.yml` | Computed values, never shown (`when: false`) |
| `essential.yml` | Required information, asked before the strategy choice |
| `strategy.yml` | The strategy selection and the derived `DefaultFor*`/`WhenFor*` variables |
| `code-quality.yml` | Formatting, linting, testing strategy |
| `community.yml` | Docs, CHANGELOG, citation, contribution, `AGENTS.md` |
| `ci.yml` | GitHub Actions workflows and the aggregate folder flags |

`copier.yml` itself only contains the `!include` lines and settings such as `_skip_if_exists`, so a new question normally does **not** go there.

Follow the other questions' style and syntax. The gist of it is that you need:

```yaml
AddMyFeature:
  when: "{{ WhenForLight }}"        # See the strategy system above
  type: bool                        # bool, str, or int
  default: "{{ DefaultForLight }}"  # Matches the level used in `when`
  help: Add my feature (Longer description shown in the interactive prompt)
  description: |
    What this feature does and why you would want it, in as much detail as needed.

    Strategy: Light
```

- A **`PascalCase`** name. Use the `Add*` prefix for booleans that add files (`AddDocs`, `AddChangelog`), `Check*`/`Run*` for behaviors (`CheckExplicitImports`, `RunJuliaNightlyOnCI`), and no prefix for basic information (`PackageName`, `License`).
- A **`when`**, using the `WhenFor*` variable of the [strategy level](@ref strategy_system) you are targeting. A question that only makes sense together with another one keys off its parent as well, e.g. `when: "{{ AddPrecommit and WhenForAdvanced }}"`.
- A **`type`**.
- A **`help`**, in the form `Short title (Longer description and details)`.
- A **`default`**, using the `DefaultFor*` variable matching the `when`.
- A **`description`**, which is not part of `copier` — we use it to describe the question to users in the documentation (it gets rendered in [Questions](@ref)).

!!! warning "The `description` must end with a `Strategy:` line"
    The [Questions](@ref) page parses the `copier/*.yml` files and looks for `Strategy: <Level>` inside every `description`.
    A question outside `essential.yml` and `strategy.yml` without that line makes the documentation build fail.

Optional fields, when they apply: `choices:` (a map of `"Display name": value`), `validator:` (a Jinja2 expression that returns an empty string when the answer is valid), and `placeholder:`.
If you think your question needs one of these, look at the existing questions first — `TestingStrategy` and `License` for `choices`, `PackageName` and `JuliaIndentation` for `validator`, and `Authors` for `placeholder` — and follow the closest one.

### Wiring a new question into the template

Adding the question to `copier/` is only the first step. Depending on what the question does, you also need:

- **The template files themselves**, gated on the new variable — see [Dependent sections in a file](@ref) and [Dependent files and directories](@ref) below.
- **Aggregate folder flags** (in `copier/ci.yml`). The `.github` and `.github/workflows` directories are themselves conditional, on `AddDotGitHubFolder` and `AddWorkflowsFolder`. If your question creates a file inside one of them, add it to the corresponding default expression, otherwise the folder is not created and the file silently disappears. Only list flags that *create* a file there; flags that merely change the content of an existing workflow (such as `AddMacToCI`) do not belong in the expression.
- **`_skip_if_exists`** (in `copier.yml`). If the generated file is meant to be edited by the user afterwards — `CHANGELOG.md`, `LICENSE`, `CITATION.cff`, `AGENTS.md` — list it here so that `update` does not overwrite their changes.
- **Cross-file references**. Grep the template for related content that should now become conditional. For instance, `AddChangelog` also had to make the release section of the generated `91-developer.md.jinja` conditional.
- **An `add_feature` entry**, if the question adds a self-contained file that existing packages should be able to opt into without a full update. See [Adding a new `add_feature(:feature)`](@ref).

### Testing a new question

- **Answer data** (`src/debug/Data.jl`). Add the value to the lowest strategy level where it becomes relevant; the levels merge upwards, so `light` inherits from `tiny` and so on.
- **Random values** (`test/utils.jl`). Only needed for non-trivial types: add a `_random(::Val{:MyQuestion}, value)` method. Booleans and strings without `choices` are covered by the existing fallbacks.
- **Question-level tests**, in a new `test/test-<feature>.jl`. At a minimum, check that the file is present when the question is enabled and absent when it is not, that the substituted content is correct, and that any conditional block you added to other templates appears and disappears as expected.
- **The CHANGELOG**, with an entry under `## [Unreleased]`.

An example of everything above in one place is the commit that added `AddAgentsMd` (#613): question in `copier/community.yml`, `AGENTS.md` in `_skip_if_exists`, a conditional template file, a `features.toml` entry for `add_feature(:agents)`, data in `src/debug/Data.jl`, and both `test/test-agents.jl` and `test/test-add-feature.jl`.

### Dependent sections in a file

To create a section in a file that depends on a variable, first add `.jinja` to the end of the file name and use something like

```jinja
{% if AddSomeStuff %}
...
{% endif %}
```

`AddSomeStuff` is assumed to be boolean here, but you can use other conditions, such as `{% if PackageName == 'Pkg' %}`.

Notice that the empty spaces are included as well, so in some situation you might need to make it less readable.
For instance, the code below will correctly parse into a list of three elements if `AddBob` is false.

```jinja
# Good

- Alice{% if AddBob %}
- Bob{% endif}
- Carlos
- Diana
```

While the code below will parse into two lists of one and two elements, respectively:

```jinja
# Bad
- Alice
{% if AddBob %}- Bob{% endif}
- Carlos
- Diana
```

### Dependent files and directories

To make a file depend on a variable, you can change the name of the file to include the conditional and the `.jinja` extension.

```jinja
{% if AddSomeFile %}some-file.txt{% endif %}.jinja
```

If `AddSomeFile`, then `some-file.txt` will exist.

For directories, you do the same, except that you don't add the `.jinja` extension.

```jinja
{% if AddGitHubTemplates %}ISSUE_TEMPLATE{% endif %}
```

### Using answers

To use the answers of a question outside of a conditional, you can use `{{ SomeValue }}`.
This will translate to the value of `SomeValue` as answered by the user.
For instance

```jinja
whoami() = "Hi, I'm package {{ PackageName }}.jl"
```

This also works on file names and in the `copier.yml` file.

### Raw tag and avoiding clashes in GitHub workflow files

Since the GitHub workflow also uses `{` and `}` for their commands, we want to enclose them using the `{% raw %}...{% endraw %}` tag:

```jinja
os: {% raw %}%{{ matrix.os }}{% endraw %}
```

## Removing/replacing a question

!!! warning
    This has only been tested with a single change

Before removing a question, we should deprecate it for at least one major release.
We also want to ensure a smooth transition when the user updates.

Luckily, we do have one test that minimally simulates this situation:
"Test updating from main to HEAD vs generate in HEAD" inside file `test/test-bestie-specific-api`.

This test will run `generate` using the local `main` branch (which won't contain the changes), and run the `update` command, with `defaults=true`, and then compare the result to running `generate` directly.

- Change the `help` field to start with "(Deprecated in VERSION)" (VERSION should be the next major release)
- Set `when: false` in the question
- Update the CHANGELOG
  - Entry in `Deprecated` section
  - Add or update a "Breaking notice" in the beginning to inform of the changes
- Move the default questions answers in `src/debug/Data.jl` to the `deprecated` dictionary.
- Make sure that nothing depends on the old question
- If necessary, change some `default` values to use the deprecated questions, to ensure a smooth transition.
- Remove the question in the next release

## Errors in "Test updating from main to HEAD vs generate in HEAD"

The test "Test updating from main to HEAD vs generate in HEAD" from file `test/test-bestie-specific-api` compares two generated packages:

1. Run the `generate` command using the template from the `main` branch and then run the `update` command to update to `HEAD`.
2. Run the `generate` command using the template from `HEAD`.

This will check that users of the current version of the package will not have a bad time updating.

However, some changes will unavoidably break this test.
For instance, when the LTS version changes between `main` and `HEAD`, the file `Project.toml` won't be updated, because it is skipped if it exists.
This will be a breaking change that requires manual intervention.

To avoid breaking the whole test pipeline, we use the environment variable `BESTIE_SKIP_UPDATE_TEST` to disable the test.
The variable has to be set locally for your tests and also passed to the CI via the commit message.

Here's a summary of what to do:

- Locally, inside Julia, run

  ```julia
  ENV["BESTIE_SKIP_UPDATE_TEST"] = "yes"
  ```

- In your commit message, add `BESTIE_SKIP_UPDATE_TEST` anywhere.
- Add a breaking notice to the CHANGELOG informing what is going to happen to users and what they need to do to manually fix the problem.
