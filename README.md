<p>
  <img width="150" align="right" src="docs/src/assets/logo.png">
</p>

# COPIERTemplate.jl - Copier OPInionated Evolving Reusable Template

<!-- markdown-link-check-disable -->
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://abelsiqueira.github.io/COPIERTemplate.jl/stable)
[![In development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://abelsiqueira.github.io/COPIERTemplate.jl/dev)
<!-- markdown-link-check-enable -->
[![Lint workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Build Status](https://github.com/abelsiqueira/COPIERTemplate.jl/workflows/Test/badge.svg)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions)
[![Test workflow status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Lint workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/abelsiqueira/COPIERTemplate.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/abelsiqueira/COPIERTemplate.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8350577.svg)](https://doi.org/10.5281/zenodo.8350577)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

This is

- a [copier](https://copier.readthedocs.io) template/skeleton for Julia packages (see folder [template](template)); and
- a package created with the template that wraps `copier` in Julia using `PythonCall`.

The template

- is opinionated but allows options;
- can be applied to existing packages (thanks to copier);
- is automatically reapplied through Pull Requests made by the Copier.yml workflow.

[![asciicast](https://asciinema.org/a/611189.svg)](https://asciinema.org/a/611189)

Additional wishlist

- Use as template for other templates (Maybe just use forks?)

**But why?**

Because I have around 50 packages that follow similar configuration (but not equal), and I don't want to go through all of them manually every time I have a small change.

**What about mass updates using the GitHub API?**

I have done that in the past, but now I want even less manual intervention.
This will still require manual installation for the first time, and will still allow verifying the pull requests.

## How to install

> **Warning**
>
> It is unknown if the package works on Windows due to an issue with unsupported paths.
> See [Issue #21](https://github.com/abelsiqueira/COPIERTemplate.jl/pull/21).
> If it doesn't work, let us know, and use the alternative installation.

1. Install this package, use the module and run `COPIERTemplate.generate(path)`.

   Alternatively, this can also be installed directly via [copier](https://copier.readthedocs.io), with the command

   ```bash
   copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
   ```

   Follow the instructions. In particular you will need a UUID. Your Linux might have `uuidgen` installed, but you can also use Julia:

   ```bash
   using UUIDs
   uuid4()
   ```

1. The resulting folder will not be a `git` package yet (to avoid trust issues), so you need to handle that yourself. First, install [`pre-commit`](https://pre-commit.com), and then issue:

    ```bash
    cd YourPackage.jl
    git init
    git add .
    pre-commit run -a # Fix possible pre-commit issues
    git add .
    git commit -m "First commit"
    pre-commit install # Future commits can't be directly to main unless you use -n
    ```

    It is common to have some pre-commit issues due to your package's name length triggering JuliaFormatter.

1. Create a repo on GitHub and push it

    ```bash
    git remote add origin https://github.com/UserName/PackageName.jl
    ```

1. Create a `DOCUMENTER_KEY`, which will be used by for documentation purposes.

    ```bash
    pkg> activate --temp
    pkg> add DocumenterTools
    julia> using DocumenterTools
    julia> DocumenterTools.genkeys(user="UserName", repo="PackageName.jl")
    ```

    Follow the instruction in the terminal.

1. Create a Personal Access Token to be used by the Copier workflow.

    1. Go to <https://github.com/settings/tokens>.
    1. Create a token with "Content", "Pull-request", and "Workflows" permissions.
    1. Copy the Token.
    1. Go to your YOUR_PACKAGE_URL/settings/secrets/actions.
    1. Create a "New repository secret" named `COPIER_PAT`.

1. Before releasing, enable Zenodo integration at <https://zenodo.org/account/settings/github/>.

## What are all these files?

Since there are so many files, an explanation is in order.

### Basic package structure

This structure should be self-informative, as it is part of what most people use, with a few exceptions mentioned below.

- PackageName.jl/
  - docs/
    - src/
      - 90-contributing.md
      - 90-developer.md
      - index.md
      - 90-reference.md
    - make.jl
    - Project.toml
  - src/
    - PackageName.jl
  - test/
    - Project.toml
    - runtests.jl
  - LICENSE.md
  - Project.toml
  - README.md

The exceptions are:

- `test/Project.toml`: This is supported for a while, and it looks better. Time will tell if it was a bad idea.
- `docs/src/90-contributing.md`: Also known as CONTRIBUTING.md, it explains how contributors can get involved in the project.
- `docs/src/90-developer.md`: Also known as README.dev.md, it explains how to setup your local environment.

### Linting and Formatting

The most important file related to linting and formatting is `.pre-commit-config.yaml`, which is the configuration for [pre-commit](https://pre-commit.com).
It defines a list of linters and formatters for Julia, Markdown, YAML, and JSON.

It requires installing `pre-commit` (I recommend installing it globally with `pipx`).
Installing pre-commit (`pre-commit install`) will make sure that it runs right the relevant hooks before commiting.
Additionally, if you run `pre-commit run -a`, it runs all hooks, which can be used for Linting.

Some hooks in the `.pre-commit-config.yaml` file have configuration files of their own:
`.JuliaFormatter.toml`, `.markdownlint.json`, `.markdown-link-config.json`, and `.yamllint.yml`.

Also slightly related, is the `.editorconfig` file, which tells your editor, if you install the coorect plugin, how to format some things.

### GitHub Workflows

The select a few workflows, with a strong possibility of expanding in the future:

- CompatHelper.yml: Should be well known by now. It checks that your Project.toml compat entries are up-to-date.
- Copier.yml: This will periodically check the template for updates. If there are updates, this action creates a pull request updating your repo.
- Docs.yml: Build the docs. Only runs when relevant files change.
- Lint.yml: Run the linter and formatter through the command `pre-commit run -a`.
- TagBot.yml: Create GitHub releases automatically after your new release is merged on the Registry.
- Test.yml: Run the tests.

## Users and Examples

The following are users and examples of repos using this template, or other templates based on it.
Feel free to create a pull request to add your repo.

- This package itself uses the template.
- [COPIERTemplateExample.jl](https://github.com/abelsiqueira/COPIERTemplateExample.jl)
- [JSOTemplate.jl](https://github.com/JuliaSmoothOptimizers/JSOTemplate.jl)
