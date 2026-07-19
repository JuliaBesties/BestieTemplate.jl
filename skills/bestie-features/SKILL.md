---
name: bestie-features
description: Add BestieTemplate features (AGENTS.md, changelog, dependabot, pre-commit, lint workflow, testitem runner) to a Julia package with the bestie CLI — no Julia needed. Use when asked to add one of these files/setups to a package, or to see what BestieTemplate can add.
---

# Adding Bestie features to a package

`bestie add-feature` applies a named slice of the [BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl) copier template to an existing package: only the feature's files are written, everything else is left untouched. Requires only [uv](https://docs.astral.sh/uv/) on the PATH.

Until `bestie-template` is published to PyPI, run it from the git repository (branch `api`; after release this becomes `uvx --from bestie-template bestie`):

```sh
alias bestie="uvx --from 'git+https://github.com/JuliaBesties/BestieTemplate.jl@api#subdirectory=python' bestie"
```

## Workflow

1. **Discover** what can be added:

   ```sh
   bestie list-features --json
   ```

   Each entry has `name`, `description`, `required_fields` (answers you must be able to supply), and `requires_answers` (needs an existing `.copier-answers.yml`).

2. **Apply**, from the package root (or pass the package path as second argument). Multiple features are one comma-separated argument, no spaces:

   ```sh
   bestie add-feature changelog,dependabot [PATH]
   ```

3. **Verify** with `git status` / `git diff`: only the features' files should appear, plus `.copier-answers.yml` if the package already had one.

## Answering template questions

- Answers are read from the package's `.copier-answers.yml` when it exists; anything unresolved must be passed as `-d KEY=VALUE` (repeatable).
- On `Cannot determine required fields ...`, the missing keys are listed in the message (and in the `error.missing` array in `--json` mode). Re-run with `-d Key=value` for each; infer values from the repository (e.g. `PackageName` from `Project.toml`) and confirm guesses with the user.
- Features with `requires_answers: true` refuse to run without `.copier-answers.yml`. That file must not be created by hand — it means the package never applied the full template; suggest `BestieTemplate.apply` (Julia) instead.
- The answers file is updated when present and never created.

## Machine-readable mode

Both commands accept `--json`. Failures print `{"error": {"type": ..., "message": ..., "missing": [...]?}}` and exit 1; usage mistakes exit 2. Parse the last stdout line — copier may print warnings above it.

## Version pinning

`--ref vX.Y.Z` pins the template version; the default is the latest template release. A `FeatureNotAppliedError` means the rendered template version predates that feature — pass a newer `--ref`. **While running from the unreleased branch, always pass `--ref api`** (the current release predates several features, including `agents`).
