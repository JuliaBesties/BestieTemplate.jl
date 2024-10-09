# [Full guide](@id full_guide)

Welcome to **full usage guide** of BestieTemplate.

```@contents
Pages = ["10-full-guide.md"]
Depth = 2:3
```

## Before installing

### Things to know

This template is an attempt to provide many best practices to package development.
This can be overwhelming, so you might prefer to take it easy at first and install only the fewest amount of new things possible.

Thinking of you, the first optional question in the template is how to deal with the optional questions:

- The "Recommended" option lets us select the best practices that we like the most. This means "yes" to most of the optional answers.
- The "Minimum" option does not add any optional feature. Your package will still be a valid Julia package with a few things that we deem essential (such as online testing, documentation, and CITATION.CFF).

The "Minimum" option is still a step above the bare minimum for a Julia package, so you will still benefit from the template.
The "Recommended" option adds many features that package maintainers might find useful in the long run, but might be too much at once.
Check the [Explanation](@ref explanation) page for more information.

If you decide to gradually adopt, do this:

1. Follow the relevant application section for [New](@ref new_package) or [Existing](@ref existing_package).
1. Remember to select the "Minimum" optional questions.
1. Follow the [Update section](@ref updating_package), change your answer from "Minimum" to "Recommended" or "Ask me".

### Things to install

#### EditorConfig

Install a plugin on your editor to use [EditorConfig](https://editorconfig.org).
This will ensure that your editor is configured with important formatting settings.

#### pre-commit

We recommend using [https://pre-commit.com](https://pre-commit.com) to run linters and formatters.
If you select the "recommended" options later on, you will need `pre-commit` installed.

`pre-commit` is a python package, so there are a few ways to install.
We like one of these two ways:

1. Using [pipx](https://pipx.pypa.io) as follows:

   ```bash
   pipx install pre-commit
   ```

2. Using `pip` in a virtual environment

   ```bash
   python -m venv env
   source env/bin/activate
   pip install pre-commit
   ```

#### JuliaFormatter

When using `pre-commit`, the Julia code is formatted using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl), so please install it globally first:

```julia-repl
julia> # Press ]
pkg> activate
pkg> add JuliaFormatter
```

## Install BestieTemplate (or copier)

To use the template, we recommend installing the package `BestieTemplate.jl` globally:

```julia-repl
julia> # press ]
pkg> activate
pkg> add BestieTemplate
```

The BestieTemplate package wraps [copier](https://copier.readthedocs.io/) and adds some lightweight checks and parameters to make your user experience better.

!!! warning "Alternative"
    Alternatively, you can use [copier](https://copier.readthedocs.io/) directly, in which case you will have the pure template generation experience. If that is the case, I will assume that you know what you are doing and won't show the full command here to avoid confusing new users.

## Using the template

There are three use cases on using the template:

1. You are using the template to start a [new package](@ref new_package).
1. You already have a Julia project and you want to [apply the template to your project](@ref existing_package).
1. You already uses the template and you want to [update to get the latest changes](@ref updating_package).

The three cases are listed below.

### [New package](@id new_package)

Simply run

```julia-repl
julia> using BestieTemplate
julia> BestieTemplate.generate("full/path/to/YourPackage.jl")
```

This will create the folder at the given path and create a package named `YourPackage` using the latest release of the BestieTemplate.
You will be prompted with many questions, **some required** and some with our **recommended** choices.

You can give more options to the `generate` function, including the source of the template, pre-filled data, and options passed to the underlying project generator `copier`.
See the full docstring for [`BestieTemplate.generate`](@ref) for more information.

The resulting folder will not be a `git` package yet (to avoid trust issues), so you need to handle that yourself.
You should see a short guide on screen, but here it is again:

```bash
cd full/path/to/YourPackage.jl
git init
git add .
pre-commit run -a # Try to fix possible pre-commit issues (failures are expected)
git add .
git commit -m "First commit"
pre-commit install # Future commits can't be directly to main unless you use -n
```

Now, create a new repository on [GitHub](https://github.com) and push your code.
We won't give you details on how to do this, but you can check [The Turing Way](https://the-turing-way.netlify.app/collaboration/github-novice).

After that, jump on to [Setting up your package](@ref).

### [Applying to an existing package](@id existing_package)

To apply the template to an existing package, you can do the following:

!!! warning "git"
    This assumes that you already use git on that package and the your working directory is clean.
    It will fail otherwise.

```julia-repl
julia> using BestieTemplate
julia> BestieTemplate.apply("full/path/to/YourPackage.jl")
```

This command will look around your project path and try to guess some of the answers.
Currently, we guess:

- `PackageName` and `PackageUUID` from the `name` and `uuid` fields in `Project.toml`,
- `Authors` from the `authors` field in `Project.toml`,
- `PackageOwner` from the `repo` in `docs/make.jl`,
- `JuliaMinVersion` from the `compat` section in `Project.toml`,
- `JuliaIndentation` from the `indent` field in `.JuliaFormatter.toml`.

!!! tip "Overwrite"
    You will be asked whether to overwrite existing files or not. Since you are using `git`, you can try it out and reset if you don't like the result. So we recommend overwriting at this point.

If you don't like the result, or want to override the answers, you can run the `apply` function with additional arguments, for instance:

```julia-repl
julia> data = Dict("Authors" => "Bob <bob@bob.br>")
julia> BestieTemplate.apply("full/path/to/YourPackage.jl", data)
```

Alternatively, you can also tell Bestie to not guess:

```julia-repl
julia> BestieTemplate.apply("full/path/to/YourPackage.jl"; guess = false)
```

See the full docstring for [`BestieTemplate.apply`](@ref) for more information.

!!! warning "Review the changes"
    Don't just add the changes blindly, because some of your files can and will be overwritten.

!!! warning "README.md conflicts"
    We really can't avoid some conflicts, and although some file can be skipped if existing (such as CITATION.cff), some can't.
    For instance, README.md will most likely be wrong when you apply the template, but the badges (for instance), need to be included in your project.
    This means that README.md cannot be skipped, and you will have to accept the overwrite and manually fix your README.md.

!!! tip "Formatting"
    You might most likely see changes in the formatting. So if you have a formatter, it might be best to run it before reviewing the changes.
    If you have chosen the "Recommended" answers, or explicitly chose to add `pre-commit`, then you should use it now (see below).

If you need some help with undoing some of these changes, I recommend using a graphical interface for git.
After the template is applied and you are happy with the conflict resolution, enable pre-commit and push your code.

```bash
git add .
pre-commit run -a # Try to fix possible pre-commit issues (failures are possible)
pre-commit install # All commits will run pre-commit now
git add .
git commit -m "Apply BestieTemplate vx.y.z"
```

Push your code to GitHub and head to [Setting up your package](@ref) for information on what to do next.

Now, go to [Setting up your package](@ref) to check what you still need to configure for your package.

### [Updating](@id updating_package)

To update the package, simply call

```julia-repl
julia> BestieTemplate.update()
```

You will be asked the relevant questions of the package as if you had applied it.
The big differences are:

- It will only apply the things that are new since you last applied/updated
- It will remember previous answer.
- It will overwrite without asking.

!!! tip "Change previous answers"
    You can change your previous answers. In other words, if you though something was not mature enough in the past, but you are more confident in that now, you can adopt it now.
    This works even if the template was not updated itself.

As with the first application, you need to run `pre-commit run -a` to fix the unavoidable linting and formatting issues.
Check the modifications in the relevant linter and formatting files, if you changed them manually, before doing it, though.

```bash
pre-commit run -a
```

You will possibly have conflicts when you apply the template - i.e., updates to the template that conflicts with changes that you've made to the package.
Whenever a conflict appears, you will need to decide on whether to accept or reject the new changes.
Fix the conflicts using `git`.

The underlying package `copier` will use `git` to apply the differences and it will overwrite whatever files it finds in the way.
Since `git` is mandatory, the changes will be left for you to review.

!!! warning "Review the changes"
    I repeat, the changes will be left for you to review.
    Don't just add them blindly, because some of your modifications can and will be overwritten.

If you need some help with undoing some of these changes, I recommend using a graphical interface to git.

## Setting up your package

There are various steps to setting up your package on GitHub. Some are important now, and some will be relevant when you try to make your first release.

### Add to GitHub

If you haven't yet, create a repo on GitHub and push your code to it.

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

#### Documentation for releases

!!! info
    This section is only relevant when making your first release, but it might be better to get it out of the way now.

You need to set a `DOCUMENTER_KEY` to build the documentation from the tags automatically when using TagBot (which we do by default).
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

### Add key for Copier.yml workflow

!!! warning "Copier.yml is work in progress"
    This option is not selected by default because it is a work in progress.
    If you want to use it, you have to pass the key `"AddCopierCI" => true` to the `data` argument of `generate` or `apply`, or select "Ask me" when deciding how to answer the optional questions.

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

### First release

When you are ready to make your first release, enable the [Julia Registrator bot](https://github.com/apps/juliateam-registrator/installations/select_target).
Make sure that you haven't skipped these sections:

- [Documentation for releases](@ref)
- [CITATION.cff and Zenodo deposition](@ref)
