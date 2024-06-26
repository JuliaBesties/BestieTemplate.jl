# [Explanation](@id explanation)

In this section, we hope to explain the motivation for the package, and what is inside the template.
Some things might have been obvious when creating the package and not at the moment, so feel free to create issues to ask, or suggest, clarifications.

!!! tip
    If something is missing or not explained enough, please open an issue.

## The engine, the project generator, and the template

Let me start by marking some names clearer.

- The **template** is the collection of files and folders written with some placeholders. For instance, the link to a GitHub project will be something like `https://github.com/{{ PackageOwner }}/{{ PackageName }}.jl`.
- The **engine** is the tool that converts the template into the end result, by changing the placeholders into the actual values that we want.
- The **project generator** is the tool that interacts with the user to get the placeholder values and give to the engine.

## Comparison with existing solutions

Julia has a very good package generator called [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl), so why did we create another one?

The short answer is that we want a more streamlined development experience, a template more focused on _best practices_, and the ability to keep reusing the template whenever new tools and ideas are implemented.

In more details, first, see the differences in the parts of the project in the table below:

|                   | BestieTemplate.jl                                                          | PkgTemplates.jl                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------- |
| Template          | Part of the package                                                        | Part of the package                     |
| Engine            | [Jinja](https://palletsprojects.com/p/jinja)                               | [Mustache](https://mustache.github.io/) |
| Project generator | [copier](https://copier.readthedocs.io), with some wrappers in the package | Part of the package                     |

Now, we can split this into three comparisons.

### Template differences

The template differences are mostly due to opinion and contributions and it should be easy to translate files from one template to the other.
We are heavily inspired by PkgTemplates.jl, as we used it for many years, but we made some changes in the hopes of improving _software sustainability_, _package maintainability_ and _code quality_ (which we just overtly simplify as best practices).
As such, our current differences (as of the time of writing) are:

- We have more _best practices_ tools, such as pre-commit, configuration for linters and formatters for Julia, Markdown, TOML, YAML and JSON, CITATION.cff, Lint GitHub workflow, `.editorconfig` file, issues and pull requests templates, etc.
- We focus on the main use cases (GitHub and GitHub actions), so we have much less options.

### Engine differences

We can't say much about these, since we don't know or care in details.

### Project generator differences

PkgTemplates.jl is a project generator. This means that if you want to programmatically create templates inside Julia, this is the best solution.
The questions (user interface) are implemented by the package, which then translates that into the answers for the engine.
Disclaimer: We haven't worked on the package, this information is based on the docs.

We use [copier](https://copier.readthedocs.io) as project generator.
It is an external Python tool, so we also include some wrappers in the package to use it from Julia without the need to explicitly install it.
Copier has many features, so we recommend that you check [their comparisons pages](https://copier.readthedocs.io/en/stable/comparisons/) for more information.

Most notably, the feature that made us choose copier in the first place has the ability to **applied and reapplied to existing projects**.
This means that existing packages can benefit from all best practices that we provide.
Furthermore, they can keep reaping benefits when we create new versions of the template.

## Template details

Let's dive into the details of the template now.

### Basic package structure

This is the basic structure of a package:

- PackageName.jl/
  - src/
    - PackageName.jl
  - test/
    - Project.toml
    - runtests.jl
  - LICENSE.md
  - Project.toml
  - README.md

With the exception of `test/Project.toml`, all other files are requirements to register a package.

### Documentation

On top of the basic structure, we add some Documenter.jl structure.

- docs/
  - src/
    - 90-contributing.md
    - 91-developer.md
    - 95-reference.md
    - index.md
  - make.jl
  - Project.toml

Brief explanation of the details:

- The `Project.toml`, `make.jl` and `src/index.md` are the basic structure.
- `docs/src/90-contributing.md`: Sometimes added as CONTRIBUTING.md, it explains how contributors can get involved in the project.
- `docs/src/91-developer.md`: Sometimes added as README.dev.md or DEVELOPER.md, it explains how to setup your local environment and other information relevant for developers only.
- `docs/src/95-reference.md` is the API reference page, which include an `@autodocs`.

One noteworthy aspect of our `make.jl`, is that we include some code to automatically generate the list of pages.
Create a file in the form `##-name.md`, where `##` is a two-digit number, and it will be automatically added to the pages list.

!!! info "index.md"
    You might have noticed that index.md is not numbered, and that is because Documenter.jl checks for that files specifically to define the landing page. Instead, we explicitly add `"Home" => "index."` to `make.jl`.

### Linting and Formatting

The most important file related to linting and formatting is `.pre-commit-config.yaml`, which is the configuration for [pre-commit](https://pre-commit.com).
It defines a list of linters and formatters for Julia, Markdown, TOML, YAML, and JSON.

It requires installing `pre-commit` (I recommend installing it globally with `pipx`).
Installing pre-commit (`pre-commit install`) will make sure that it runs the relevant hooks before committing.
Furthermore, if you run `pre-commit run -a`, it runs all hooks.

Some hooks in the `.pre-commit-config.yaml` file have configuration files of their own:
`.JuliaFormatter.toml`, `.markdownlint.json`, `lychee.toml`, and `.yamllint.yml`.

Also slightly related, is the `.editorconfig` file, which tells your editor, if you install the correct plugin, how to format some things.

### GitHub Workflows

We have a few workflows, with plans to expand in the future:

- CompatHelper.yml: Should be well known by now. It checks that your Project.toml compat entries are up-to-date.
- Copier.yml: This will periodically check the template for updates. If there are updates, this action creates a pull request updating your repo.
- Docs.yml: Build the docs. Only runs when relevant files change.
- Lint.yml: Run the linter and formatter through the command `pre-commit run -a`.
- TagBot.yml: Create GitHub releases automatically after your new release is merged on the Registry.
- For testing, we have
  - ReusableTest.yml: Defines a reusable workflow with the testing.
  - Test.yml: Defines a matrix of tests to be run whenever `main` is updated or a tag is created. Uses the ReusableTest workflow. If "Simplified PR Test" was not chosen, then this also runs when there are pull requests.
  - TestOnPRs.yml: Defines a test to be run when pull requests are created. Only the latest stable Julia version is tested on a ubuntu-latest image. Uses the ReusableTest workflow. If "Simplified PR Test" was not chosen, then this file does not exist.

### Issues and PR templates

We include issues and PR templates for GitHub (see `.github/`).
These provide a starting point to your project management.

### Other files

- .cirrus.yml: For [Cirrus CI](https://cirrus-ci.org), which we use solely for FreeBSD testing.
- CITATION.cff: Instead of the more classic `.bib`, we use `.cff`, which serves a better purpose of providing the metadata of the package. CFF files have been adopted by GitHub, so you can generate a BibTeX entry by clicking on "Cite this repository" on the repository's main page. CFF files have also been adopted by [Zenodo](https://zenodo.org) to provide the metadata of your deposition.
- CODE\_OF\_CONDUCT.md: A code of conduct file from [Contributor Covenant](https://www.contributor-covenant.org).
