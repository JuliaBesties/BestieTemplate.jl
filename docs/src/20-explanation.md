# [Explanation](@id explanation)

In this section, we hope to explain the motivation for the package, and what is inside the template.
Some things might have been obvious when creating the package and not at the moment, so feel free to create issues to ask, or suggest, clarifications.

You can see all questions in details in the [Questions](@ref) page.

!!! tip
    If something is missing or not explained enough, please open an issue.

## The engine, the project generator, and the template

Let me start by making some names clearer.

- The **template** is the collection of files and folders written with some placeholders. For instance, the link to a GitHub project will be something like `https://github.com/{{ PackageOwner }}/{{ PackageName }}.jl`.
- The **engine** is the tool that converts the template into the end result, by changing the placeholders into the actual values that we want.
- The **project generator** is the tool that interacts with the user to get the placeholder values and give to the engine.

## Comparison with existing solutions

Julia has a very good package generator called [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl), so why did we create another one?

The short answer is that we want a more streamlined development experience, a template more focused on _best practices_, and the ability to keep reusing the template whenever new tools and ideas are implemented.
Implementing these things inside `PkgTemplates.jl` would involve much more work and maintenance than creating a new tool based on existing software, so we decided to go that way.

In more details, first, see the differences in the parts of the project in the table below:

|                   | BestieTemplate.jl                                                          | PkgTemplates.jl                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------- |
| Template          | Part of the package                                                        | Part of the package                     |
| Engine            | [Jinja](https://palletsprojects.com/p/jinja)                               | [Mustache](https://mustache.github.io/) |
| Project generator | [copier](https://copier.readthedocs.io), with some wrappers in the package | Part of the package                     |

Now, we can split this into three comparisons.

### Template differences

The template differences are mostly due to opinion and contributions and it should be easy to translate files from one template to the other.
See [issue #353](https://github.com/JuliaBesties/BestieTemplate.jl/issues/353) for a list of what is missing and if you want to contribute.
We are heavily inspired by PkgTemplates.jl, as we used it for many years, but we made some changes in the hopes of improving _software sustainability_, _package maintainability_ and _code quality_ (which we just overtly simplify as best practices).
As such, our current differences (as of the time of writing) are:

- We have more _best practices_ tools, such as pre-commit, configuration for linters and formatters for Julia, Markdown, TOML, YAML and JSON, CITATION.cff, Lint GitHub workflow, `.editorconfig` file, issues and pull requests templates, etc.
- We focus on the main use cases (GitHub and GitHub actions), so we have much less options.

### Engine differences

We can't say much about these (Jinja and Mustache), since we don't know or care in details.
We use what the project generator requires (see below).

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

### Option selection strategy

The template contains some essential questions (such as authors and license) and then many optional questions.
What we call the **selection strategy** is a choice that determines the default value for the optional questions.
The strategies are:

- **Minimalistic selection**: This will be the closest to a bare-bones package the BestieTemplate will provide. Since we incentivize the addition of best practices, we don't recommend this option, even for beginners.
- **Light selection**: This will add a reasonable amount of items to your package, including automated testing and documentation. This is the minimum we recommend, and it includes many common things that you'll find in the Julia ecosystem.
- **Moderate selection**: This starts to include some practices that are not always common in Julia, but we believe are great additions. This option is great for most people. In particular, for packages with a single developer, this is a great starting point.
- **Robust selection**: Most options will be added to your package. This option is good for larger packages with already a few contributors, to allow better maintenance.

After this selection, you can choose to "confirm each question", which will show you every question you selected above and ask for a "Y/n" confirmation (defaults to yes).
After that, you can choose to "be asked other questions", which will show you every other unselected question and ask for "y/N" decision (default to no).

The motivation behind each strategy and more rationale on why an option is in one strategy or another is in the subsections below:

#### Minimalistic strategy

The "Minimalistic" strategy is the closest Bestie has to a bare-bones package. I.e., your package can be installed, tested and registered. It is close to `pkg> generate`. You probably want more than that, unless you have a specific use in mind. Things in the "Minimalistic" strategy are not behind any question, i.e., they are mandatory.

!!! note "Incomplete"
    At the moment, this options adds more than promised.

#### Light strategy

The "Light" strategy is the least amount of options to what we most people expect in a Julia package. This includes documentation and online testing, for example.
Some normal use cases for the light strategy are:

- You want a simple package, but with the batteries included.
- You are developing solo and wants to "move fast and break things".
- You want to quickly prototype something that might not even be released.
- Your package is in very early stage.

Our **loose** criteria to make something part of the light strategy are (exceptions may apply):

- Most Julia packages have it.
- Most Julia developers know what it does.
- It is a common practice, file, or tool _inside the Julia ecosystem_ (e.g., `TagBot.yml` and `CompatHelper.yml`).

#### Moderate strategy

The "Moderate" strategy extends the light strategies with best-practices that are less common, but not too niche.
Some normal use cases for the moderate strategy are:

- You want more best practices than the usual Julia package development.
- You want a compromise between old practices and new ones.

Our **loose** criteria to make something part of the moderate strategy are (exceptions may apply):

- It is not too intrusive to development (e.g., `.editorconfig`).
- It is a good recommendation that we think you should adopt (e.g., `CITATION.cff`).
- It is a common practice, file, or tool _in general_ (e.g., link checking).

#### Robust strategy

The "Robust" strategy includes everything so far and adds things that we believe will improve quality and sustainability of packages.
Normal use cases for the robust strategy are:

- You have a large package or a collection of packages;
- You are not developing the package alone;
- You expect open source contributions;
- You agree with the best practices.

Our **loose** criteria to make something part of the robust strategy are (exceptions may apply):

- Despite being good, it requires change of behaviour (e.g., `pre-commit`);
- It does not make sense for solo devs (e.g., `all-contributors`);
- It creates friction - which is good to ensure quality but slows development (e.g., issue templates).

#### Advanced options

Finally, there are **other optional features** that are not part of any strategy because they are much more specific or experimental.
This means that they will only be shown if you answer "yes" to the question "Do you want to be asked other questions?" that appears after selecting the strategy.

The **loose** criteria to make something advanced, ans thus not default for any strategy, are:

- It is a best practice, but for a niche audience (e.g., `.cirrus.yml` for testing on FreeBSD);
- It is potentially disruptive (e.g., testing on Nightly)

To see all the questions, head to [Questions](@ref).

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
`.JuliaFormatter.toml`, `.markdownlint.json`, `.lychee.toml`, and `.yamllint.yml`.

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
