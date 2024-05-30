# [Developer documentation](@id dev_docs)

If you haven't, please read the [Contributing guidelines](90-contributing.md) first.

## Linting and formatting

Install a plugin on your editor to use [EditorConfig](https://editorconfig.org).
This will ensure that your editor is configured with important formatting settings.

We use [https://pre-commit.com](https://pre-commit.com) to run the linters and formatters.
In particular, the Julia code is formatted using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl), so please install it globally first.

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

## First time clone

If this is the first time you work with this repository, follow the instructions below to clone the repository.

1. Fork this repo
2. Clone your repo (this will create a `git remote` called `origin`)
3. Add this repo as a remote:

   ```bash
   git remote add orgremote https://github.com/abelsiqueira/COPIERTemplate.jl
   ```

## Working on a new issue

1. Fetch from the JSO remote and fast-forward your local main

   ```bash
   git fetch orgremote
   git switch main
   git merge --ff-only orgremote/main
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
- If necessary, add a body with details.

### Before creating a pull request

- [Advanced] Try to create "atomic git commits" (recommended reading: [The Utopic Git History](https://blog.esciencecenter.nl/the-utopic-git-history-d44b81c09593)).
- Make sure the tests pass.
- Make sure the pre-commit tests pass.
- Fetch any `main` updates from upstream and rebase your branch, if necessary:

   ```bash
   git fetch orgremote
   git rebase orgremote/main BRANCH_NAME
   ```

- Then you can open a pull request and work with the reviewer to address any issues.

## Tips

### Testing local changes

To test you local modifications, you can run copier with the `--vcs-ref HEAD` flag and point to your local clone. This will use the latest changes, including uncommitted modifications (i.e., the dirty state).
What I normally do is this:

```bash
cd $(mktemp -d) # Go to a tmp folder
copier copy --vcs-ref HEAD /path/to/clone/ pkg # Clone dirty clone into pkg
```

### Making a new release

Simple steps:

- Create a branch `release-x.y.z`
- Update `version` in `Project.toml`
- Update the `CHANGELOG.md`:
  - Rename the section "Unreleased" to "[x.y.z] - yyyy-mm-dd" (i.e., version under brackets, dash, and date in ISO format)
  - Add a new section on top of it named "Unreleased"
  - Add a new link in the bottom for version "x.y.z"
  - Change the "[unreleased]" link to use the latest version - end of line, `vx.y.z ... HEAD`.
- Create a commit "Release vx.y.z", push, create a PR, wait for it to pass, merge the PR.
- Go back to main screen and click on the latest commit (link: <https://github.com/abelsiqueira/COPIERTemplate.jl/commit/main>)
- At the bottom, write `@JuliaRegistrator register`

After that, you only need to wait and verify:

- Wait for the bot to comment (should take < 1m) with a link to a RP to the registry
- Follow the link and wait for a comment on the auto-merge
- The comment should said all is well and auto-merge should occur shortly
- After the merge happens, TagBot will trigger and create a new GitHub tag. Check on <https://github.com/abelsiqueira/COPIERTemplate.jl/releases>
- After the release is create, a "docs" GitHub action will start for the tag.
- After it passes, a deploy action will run.
- After that runs, the [stable docs](https://abelsiqueira.github.io/COPIERTemplate.jl/stable) should be updated. Check them and look for the version number.
