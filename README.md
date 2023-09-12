<p>
  <img width="150" align="right" src="docs/src/assets/logo.png">
</p>

# COPIERTemplate.jl - Copier OPInionated Evolving Reusable Template

This is a [copier](https://copier.readthedocs.io) template/skeleton for Julia packages.

- It is opinionated but allows options
- Can be used in existing package (thanks for copier)
- Automatically keeps track of changes in the template through Pull Requests

Additional wishlist

- Use as template for other templates
- Allow using the template directly from Julia instead of installing copier (through PythonCall, possibly)

**But why?**

Because I have around 50 packages that follow similar configuration (but not equal), and I don't want to go through all of them manually every time I have a small change.

**What about mass updates using the GitHub API?**

I have done that in the past, but now I want even less manual intervention.

## How to install

1. Install [copier](https://copier.readthedocs.io).

2. Run copier with this template

    ```bash
    copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
    ```

3. Follow the instructions. In particular you will need a UUID. Your Linux might have `uuidgen` installed, but you can also use Julia:

    ```bash
    using UUIDs
    uuid4()
    ```

4. The resulting folder will not be a `git` package yet (to avoid trust issues), so you need to handle that yourself.

    ```bash
    cd YourPackage.jl
    git init
    git add .
    git commit -m "First commit"
    ```

5. Create a repo on GitHub and push it

    ```bash
    git remote add origin https://github.com/UserName/PackageName.jl
    ```

6. Create a `DOCUMENTER_KEY`, which will be used by for documentation purposes.

    ```bash
    pkg> activate --temp
    pkg> add DocumenterTools
    julia> using DocumenterTools
    julia> DocumenterTools.genkeys(user="UserName", repo="PackageName.jl")
    ```

    Follow the instruction in the terminal.

7. Create a Personal Access Token to be used by the Compliance workflow.

    1. Go to <https://github.com/settings/tokens>.
    2. Create a token with "Content", "Pull-request", and "Workflows" permissions.
    3. Copy the Token.
    4. Go to your YOUR_PACKAGE_URL/settings/secrets/actions.
    5. Create a "New repository secret" named `COMPLIANCE_PAT`.

## What are all these files?

Since there are so many files, an explanation is in order.

### Basic package structure

This structure should be self-informative, as it is part of what most people use, with a few exceptions mentioned below.

- PackageName.jl/
  - docs/
    - src/
      - contributing.md
      - developer.md
      - index.md
      - reference.md
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
- `docs/src/contributing.md`: Also known as CONTRIBUTING.md, it explains how contributors can get involved in the project.
- `docs/src/developer.md`: Also known as README.dev.md, it explains how to setup your local environment.

### Linting and Formatting

The most important file related to linting and formatting is `.pre-commit-config.yaml`, which is the configuration for [pre-commit](https://pre-commit.com).
It defines a list of linters and formatters for Julia, Markdown, YAML, and JSON.

It requires installing `pre-commit` (I recommend installing it globally with `pipx`).
Installing pre-commit (`pre-commit install`) will make sure that it runs right the relevant hooks before commiting.
Additionally, if you run `pre-commit run -a`, it runs all hooks, which can be used for Linting.

Some hooks in the `.pre-commit-config.yaml` file have configuration files of their own:
`.JuliaFormatter.toml`, `.markdownlint.json`, and `.yamllint.yml`.

Also slightly related, is the `.editorconfig` file, which tells your editor, if you install the coorect plugin, how to format some things.

### GitHub Workflows

The select a few workflows, with a strong possibility of expanding in the future:

- CompatHelper.yml: Should be well known by now. It checks that your Project.toml compat entries are up-to-date.
- Compliance.yml: This will periodically check the template for updates. If there are updates, this action creates a pull request updating your repo.
- Docs.yml: Build the docs. Only runs when relevant files change.
- Lint.yml: Run the linter and formatter through the command `pre-commit run -a`.
- TagBot.yml: Create GitHub releases automatically after your new release is merged on the Registry.
- Test.yml: Run the tests.

## Users and Examples

The following are users and examples of repos using this template.
Feel free to create a pull request to add your repo.

_Empty_.
