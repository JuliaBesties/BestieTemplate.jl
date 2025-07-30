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

## Testing

As with most Julia packages, you can just open Julia in the repository folder, activate the environment, and run `test`:

```julia-repl
julia> # press ]
pkg> activate .
pkg> test
```

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

## Additions to the templates

!!! info "Suggestions are not here"
    This section is aimed at the developer working on a new question, if you have any new idea or think the template needs to be updated or fixed, please search our [issues](https://github.com/JuliaBesties/BestieTemplate.jl/issues) and if there isn't anything relevant, open a new issue.

### Creating a new question

To create a new question, you have to open the file `copier.yml` in the root.
Find an appropriate place to add the question. Comments help identify the optional sections in the file.

Follow the other questions style and syntax. The gist of it is that you need:

- A `CamelCase` name.
- `when: "{{ AnswerStrategy == 'ask' }}"` if the question is optional but should be automatically selected for "Recommended only".
- `when: "{{ AnswerStrategy == 'ask' or AnswerStrategy == 'recommended-ask' }}"` if the question is extra.
- A `type`.
- A `help: Short description or title (Longer description and details)`.
- A `default`, if the question is optional.
  - To default to `true` if "Recommended" or `false` for "Minimum", use `{{ AnswerStrategy != 'minimum' }}`.
- A `description`, which is not actually part of `copier`, but we use to further describe the question to users in the documentation (it gets rendered in [Questions](@ref)).

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
