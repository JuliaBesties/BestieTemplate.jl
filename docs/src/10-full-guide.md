# [Full guide](@id full_guide)

Welcome to **full usage guide** of COPIERTemplate.

## Before installing

1. We highly recommend that you install [`pre-commit`](https://pre-commit.com). Our whole linting is based on that tool, so you might want to adopt it locally.
1. Decide if you are going to install `copier` or use our Julia interface.
1. If you use `copier` directly, find a UUID version 4 generator.
   - On Linux and MacOS, you can run `uuidgen`
   - On Julia, you can run `using UUIDs; uuid4()`
   - Online, you can try [uuidgenerator.net](https://www.uuidgenerator.net/version4)

## Installation

To install with COPIERTemplate.jl, install the package, use it, and run `COPIERTemplate.generate(path)`.

Alternatively, this can also be installed directly via [copier](https://copier.readthedocs.io), with the command

```bash
copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
```

Many questions will be asked. The explanation on them should be sufficient (if they aren't, please let us know).

## Post-installation

### Add to GitHub

The resulting folder will not be a `git` package yet (to avoid trust issues), so you need to handle that yourself.
Here is a short example:

```bash
cd YourPackage.jl
git init
git add .
pre-commit run -a # Try to fix possible pre-commit issues (failures are expected)
git add .
git commit -m "First commit"
pre-commit install # Future commits can't be directly to main unless you use -n
```

It is common to have some pre-commit issues due to your package's name length triggering JuliaFormatter.

Create a repo on GitHub and push your code to it.

!!! info
    The actions will run and you will see errors in the documentation and linting. Do not despair.

### Documentation

Go to your package setting on Github and find the "Actions" tab, the "General" link.
On that page, find the "Workflow permissions" and change the selection to "Read and write permissions", and enable "Allow GitHub Actions can create and approve pull requests".
This will allow the documentation workflow to work for development.

Go to the Actions page, click the failing Docs workflow and click on "re-run all jobs". It should pass now.

Now, go to your package setting on GitHub and find the "Pages" link.
You should see an option to set the **Source** to "Deploy from a branch", and select the branch to be "gh-pages" and to deploy from the "/ (root)".

After circa 1 minute, you can check that the documentation was built properly.

!!! info
    At this point, you should have passing workflows.
    1. Tests should have been passing from the start.
    2. Lint was fixed when we pushed the code to GitHub.
    3. Docs was fixed with the permissions change.

You will still need to set a `DOCUMENTER_KEY` to build the documentation from the tags automatically when using TagBot (which we do by default).
Do the following:

```bash
pkg> activate --temp
pkg> add DocumenterTools
julia> using DocumenterTools
julia> DocumenterTools.genkeys(user="UserName", repo="PackageName.jl")
```

Follow the instruction in the terminal.

### Enable Codecov for code coverage

If you don't have a Codecov account, go to <https://codecov.io> and create one now.
After creating an account and logging in, you will see your main page with a list of your packages.
Select the one that you are creating, it will open a configuration page.

On the configuration page, select "Using GitHub Actions" as your CI.
The first step in the list given you the `CODECOV_TOKEN`. Click on the "repository secret" link on that page.
It should lead you to the GitHub settings > secrets and variables > actions, under a "New secret" screen.
Write `CODECOV_TOKEN` on the "Name" field and paste the token that you see on codecov on the "Secret" field.
Click "Add secret".

Step 2 is not necessary because it is already present in the template.

The next time that the tests are run, the coverage page will be updated, and the badge will be fixed.

### Add key for Copier.yml workflow (or delete it)

You can reapply the template in the future. This is normally a manual job, specially because normally there are conflicts.
That being said, we are experimenting with having a workflow that automatically checks whether there are updates to the template and reapplies it.
A Pull Request is created with the result.

!!! warning
    This is optional, and in development, so you might want to delete the workflow instead.

If you decide to use, here are the steps to set it up:

1. Create a Personal Access Token to be used by the Copier workflow.
1. Go to <https://github.com/settings/tokens>.
1. Create a token with "Content", "Pull-request", and "Workflows" permissions.
1. Copy the Token.
1. Go to your `YOUR_PACKAGE_URL/settings/secrets/actions`.
1. Create a "New repository secret" named `COPIER_PAT`.

### CITATION.cff and Zenodo deposition

Update your `CITATION.cff` file with correct information.
You can use [cffinit](https://citation-file-format.github.io/cff-initializer-javascript/#/) to generate it easily.

Before releasing, enable Zenodo integration at <https://zenodo.org/account/settings/github/> to automatically generate a deposition of your package, i.e., archive a version on Zenodo and generate a DOI.

### Update README.md

1. Update the badges
1. Add a description

### Enable discussions

Enable GitHub discussions.
