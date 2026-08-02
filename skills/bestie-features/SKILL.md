---
name: bestie-features
description: Add BestieTemplate features (AGENTS.md, changelog, dependabot, pre-commit, lint workflow, testitem runner) to a Julia package with the bestie CLI — no Julia needed. Use when asked to add one of these files/setups to a package, or to see what BestieTemplate can add.
---

# Adding Bestie features to a package

`bestie add-feature` applies a named slice of the [BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl) copier template to an existing package: only the feature's files are written, everything else is left untouched. Requires only [uv](https://docs.astral.sh/uv/) on the PATH.

`bestie` in the commands below stands for this full invocation:

```sh
uvx --from bestie-template bestie
```

(The `--from` is needed because the package is `bestie-template` and its command is `bestie`.)
Inline the full invocation in every command — do not rely on a shell alias or variable, which won't survive when each command runs in a fresh shell.

## Workflow

1. **Discover** what can be added:

   ```sh
   bestie list-features --json
   ```

   Each entry has `name`, `description`, `required_fields` (answers you must be able to supply), and `requires_answers` (needs an existing `.copier-answers.yml`). Feature names are exact (e.g. the testitem runner is `testitem_cli`, not `testitem`); if you pass a name that doesn't exist, the error lists every valid name.

2. **Apply**, from the package root (or pass the package path as second argument). Multiple features are one comma-separated argument, no spaces:

   ```sh
   bestie add-feature changelog,dependabot [PATH]
   ```

3. **Verify** with `git status` / `git diff`: only the features' files should appear, plus `.copier-answers.yml` if the package already had one.

A clean diff means the feature applied, not that the package is done: a feature may require follow-up changes to files it does not own (e.g. `testitem_cli` replaces the test runner, so existing tests must be migrated to `@testitem` blocks and a `test/Project.toml` must exist). Check the feature's `description` and the rendered files for such expectations, and tell the user about any follow-up work you find.

## Answering template questions

- Answers are read from the package's `.copier-answers.yml` when it exists; anything unresolved must be passed as `-d KEY=VALUE` (repeatable).
- `Cannot determine required fields ...` names the missing keys and the `-d` flags to pass. Where to find the usual values: `PackageName` is `name` in `Project.toml`; `PackageOwner` is the GitHub owner in `git remote -v`; `Authors` is `authors` in `Project.toml`. Confirm anything you had to guess with the user — a wrong value applies "successfully".
- Features with `requires_answers: true` refuse to run without `.copier-answers.yml`. That file must not be created by hand — it means the package never applied the full template; suggest `BestieTemplate.apply` (Julia) instead.
- The answers file is updated when present and never created.

## Machine-readable mode

Both commands accept `--json`. Failures print `{"error": "<message>"}` and exit 1; usage mistakes exit 2. Parse the last stdout line — copier may print warnings above it.

## Version pinning

`--ref vX.Y.Z` pins the template version; the default is the latest template release, which is what you normally want. An error saying the feature "produced none of its files" means the rendered template version predates it — pass a newer `--ref`, or `--ref main` for a feature that has not made it into a release yet.
