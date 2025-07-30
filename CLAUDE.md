# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

If necessary, check the development documentation in `docs/src/91-developer.md`.

## Architecture

Julia wrapper around Python Copier template engine for generating Julia package templates. Key components:

### Source Structure

- `src/BestieTemplate.jl`: Main module file
- `src/api.jl`: Core API functions (`generate`, `apply`, `update`)
- `src/Copier.jl`: Python integration via PythonCall
- `src/debug/`: Template testing and debugging utilities
  - `Debug.jl`: Main debug interface
  - `Data.jl`: Test data management
  - `helper.jl`: Debug helper functions
- `src/friendly.jl`: User-friendly interface functions
- `src/guess.jl`: Automatic configuration detection
- `src/utils.jl`: Utility functions

### Configuration System

- `copier.yml`: Main template configuration
- `copier/`: Modular configuration files
  - `constants.yml`: Template constants
  - `essential.yml`: Essential questions
  - `strategy.yml`: Generation strategies
  - `ci.yml`: CI/CD options
  - `code-quality.yml`: Quality assurance options
  - `community.yml`: Community file options

### Template Structure

- `template/`: Jinja2 template files for generated packages
- Conditional file inclusion: `{% if Condition %}filename{% endif %}.jinja`
- Variable substitution: `{{ VariableName }}`
- Template includes GitHub workflows, docs, tests, and configuration files

## Development Commands

**Testing**: `julia --project=. -e "using Pkg; Pkg.test()"`
**Testing via the TestItemRunner**: `julia --project=test test/runtests.jl`
**Linting**: `pre-commit run -a` (setup: `pre-commit install`)
**Docs**: `julia --project=docs -e "using LiveServer; servedocs()"`

## Testing Strategy

### Unit Tests (test/)

We use testitems (<https://www.julia-vscode.org/docs/stable/userguide/testitems/>)

- `runtests.jl`: Main test runner
- `test-bestie-specific-api.jl`: BestieTemplate-specific functionality
- `test-consistency-with-copier-cli.jl`: Copier CLI compatibility
- `test-corner-cases.jl`: Edge cases and error conditions
- `test-bad-usage-and-errors.jl`: Error handling validation
- `utils.jl`: Test utilities and helpers

### Template Testing

Note: It might out of date, so it is better to avoid until reviewed.

```julia
julia --project=.
using BestieTemplate
Dbg = BestieTemplate.Debug
cd(mktempdir())
Dbg.dbg_generate()  # minimum strategy
Dbg.dbg_generate(data_choice = :rec)  # recommended strategy
```

## Template Modification

- **Add questions**: Edit `copier.yml` or files in `copier/` directory
- **Template files**: Use Jinja2 syntax in `template/` directory
- **Conditional files**: Name with `{% if Condition %}filename{% endif %}.jinja`
- **Skip existing files**: Configured in `_skip_if_exists` in `copier.yml`
- **Breaking changes**: Set `BESTIE_SKIP_UPDATE_TEST=yes` to skip compatibility test

## Quality Assurance

- **Pre-commit hooks**: `.pre-commit-config.yaml` (Julia formatting, YAML linting, etc.)
- **Julia formatting**: `.JuliaFormatter.toml` configuration
- **Markdown linting**: `.markdownlint.json`
- **YAML formatting**: `.yamlfmt.yml` and `.yamllint.yml`
- **Link checking**: `.lychee.toml` for documentation links

## CI/CD Workflows

GitHub Actions workflows in `.github/workflows/`:

- `Test.yml`: Main test suite across Julia versions
- `TestOnPRs.yml`: PR-specific testing
- `TestGeneratedPkg.yml`: Test generated package functionality
- `Lint.yml`: Code quality checks
- `Docs.yml`: Documentation building
- `CompatHelper.yml`: Dependency updates
- `TagBot.yml`: Automated tagging
- `PreCommitUpdate.yml`: Pre-commit hook updates

## Dependencies

Requires Python Copier backend. Tests use local conda environment in `test/conda-env/` to avoid redownloading dependencies. Python dependencies managed via `CondaPkg.toml`.
