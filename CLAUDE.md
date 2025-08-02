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
**Filtered Testing**: `julia --project=test test/runtests.jl --tags fast --exclude slow`
**Linting**: `pre-commit run -a` (setup: `pre-commit install`)
**Docs**: `julia --project=docs -e "using LiveServer; servedocs()"`

## Testing Strategy

### Unit Tests (test/)

We use testitems (<https://www.julia-vscode.org/docs/stable/userguide/testitems/>)

- `runtests.jl`: CLI test runner with filtering capabilities
- `test-bestie-specific-api.jl`: BestieTemplate-specific functionality
- `test-consistency-with-copier-cli.jl`: Copier CLI compatibility
- `test-corner-cases.jl`: Edge cases and error conditions
- `test-bad-usage-and-errors.jl`: Error handling validation
- `utils.jl`: Test utilities and helpers

The test runner supports filtering by:

- `--tags tag1,tag2`: Run tests with ALL specified tags
- `--exclude tag1,tag2`: Skip tests with ANY specified tags
- `--file filename`: Run tests from files containing substring
- `--name testname`: Run tests whose name contains substring
- `--pattern text`: Run tests with name/filename containing substring
- `--list-tags`: Show available tags
- `--help`: Show usage help

### Tag-Based Test Filtering Examples

The test suite uses a comprehensive tag system for efficient filtering during development:

**Available tag categories:**

- **Test Types**: `:unit`, `:integration`, `:validation`
- **Complexity**: `:fast`, `:slow`
- **Feature Areas**: `:guessing`, `:template_application`, `:copier_compatibility`, `:license_handling`, `:error_handling`, `:package_creation`, `:update_workflow`, `:test_strategy`
- **Characteristics**: `:file_io`, `:git_operations`, `:python_integration`, `:randomized`

**Common development workflows:**

```bash
# Quick development iteration (fast tests only)
julia --project=test test/runtests.jl --tags fast --exclude slow,python_integration

# Focus on specific functionality
julia --project=test test/runtests.jl --tags guessing,unit --exclude slow
julia --project=test test/runtests.jl --tags error_handling
julia --project=test test/runtests.jl --tags license_handling

# Test specific file with relevant filters
julia --project=test test/runtests.jl --file bestie-specific --tags fast --exclude randomized

# CI-friendly: exclude slow tests for faster feedback
julia --project=test test/runtests.jl --exclude slow,python_integration

# Comprehensive but focused: test core functionality
julia --project=test test/runtests.jl --tags unit,fast --exclude python_integration
```

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

## Testing Architecture Patterns

### TestItems Organization

- **Strategy-per-testitem**: Create focused testitems for each major component/strategy rather than nested loops
- **Shared testsnippets**: Use `@testsnippet` for per-test setup (runs each time, variables directly accessible)
- **Shared testmodules**: Use `@testmodule` for one-time expensive operations like data loading/computation (runs once, accessed via module prefix)
- **Combined approach**: Use both when needed - testmodules for shared expensive operations, testsnippets for per-test variables
- **Comprehensive validation**: Each testitem should test multiple aspects (files, dependencies, behavior) in one place

Reference: [TestItems.jl Documentation](https://www.julia-vscode.org/docs/stable/userguide/testitems/)

### CLI Filtering

- **Semantic tags**: Use descriptive tags like `:test_strategy`, `:integration` for easy filtering
- **Development workflow**: `julia --project=test test/runtests.jl --tags specific_feature` during development
- **Add new tags to TAGS_DATA**: Update `test/runtests.jl` when introducing new tag categories

### Test Data Management

- **Extend debug data**: Add new strategies to `src/debug/Data.jl` for consistent test scenarios
- **Random functions**: Add `_random(::Val{:NewOption})` functions to `test/utils.jl` for new template options
- **Integration validation**: Use `act` to test generated packages in CI workflows

### Pattern Examples

**@testsnippet (per-test setup):**

```julia
@testsnippet TestData begin
  sample_input = generate_random_data()  # Fresh data each test
  expected_result = process(sample_input)
end

@testitem "Feature X works" setup=[Common, TestData] begin
  @test my_function(sample_input) == expected_result
end
```

**@testmodule (one-time expensive operations):**

```julia
@testmodule SharedAssets begin
  const REFERENCE_DATA = load_large_file("reference.json")  # Load once
  const COMPUTED_BASELINE = expensive_calculation()          # Compute once
end

@testitem "Feature Y validates correctly" setup=[Common, SharedAssets] begin
  @test validate_against(result, SharedAssets.REFERENCE_DATA)
end
```

**Combined approach:**

```julia
@testmodule ExpensiveSetup begin
  const DATASET = load_dataset()  # One-time I/O
end

@testsnippet PerTestData begin
  test_case = generate_test_case()  # Fresh per test
end

@testitem "Processing works" setup=[ExpensiveSetup, PerTestData] begin
  @test process(ExpensiveSetup.DATASET, test_case) == expected_output
end
```

## Code Development Tips

- When testing new tests, use the CLI approach to filter only the relevant files to test.
