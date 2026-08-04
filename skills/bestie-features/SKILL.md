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

   Each entry has `name`, `description`, `required_fields` (answers you must be able to supply), `requires_answers` (needs an existing `.copier-answers.yml`), and optionally `optional_files` (extra config files written only if missing, keyed by the boolean answer that enables them). Feature names are exact (e.g. the testitem runner is `testitem_cli`, not `testitem`); if you pass a name that doesn't exist, the error lists every valid name.

2. **Check the working tree before applying.** A feature overwrites its `included_files` without warning, no conflict prompt and no backup — `testitem_cli` replaces an existing `test/runtests.jl` outright, discarding whatever was there. `optional_files` are the opposite: written only if missing, so an existing one (e.g. a hand-tuned `.lychee.toml`) is left untouched. Git is the only recovery path for `included_files`, so run `git status` first:

   - Uncommitted changes to any of the feature's `included_files`: stop and tell the user those changes will be lost. Let them commit or stash before you continue.
   - A file the feature owns exists and is committed: say so and what will replace it, and get the user's go-ahead before applying.
   - Not a git repository: do not apply. There is no way to undo it.

3. **Apply**, from the package root (or pass the package path as second argument). Multiple features are one comma-separated argument, no spaces:

   ```sh
   bestie add-feature changelog,dependabot [PATH]
   ```

4. **Verify** with `git status` / `git diff`: only the feature's `included_files` should appear as modified, any missing `optional_files` as newly added, plus `.copier-answers.yml` if the package already had one. Read the diff of every pre-existing file the feature touched — "Applied 1 feature(s)" is printed just the same whether the file was created or overwritten, so success output is not evidence that nothing was lost.

A clean diff means the feature applied, not that the package is done: a feature may require follow-up changes to files it does not own (e.g. `testitem_cli` replaces the test runner, so existing tests must be migrated to `@testitem` blocks and a `test/Project.toml` must exist). Check the feature's `description` and the rendered files for such expectations, and tell the user about any follow-up work you find.

## Recommending features

When asked what a package could use rather than for a named feature, start from `list-features --json` and narrow it against the package itself. Present the result as a short list of what is missing and worth adding, with a one-line reason each; do not apply anything without the user's go-ahead.

- **Drop what is already there.** Check each feature's `included_files` against the package before recommending it. For files the template protects (see *Protected files*), the feature reports "applied" while writing nothing, so recommending one that already exists produces a no-op the user may read as a change.
- **`lint_action` needs an answers file; `lint_action_explicit` doesn't.** `lint_action` has `requires_answers: true` and fails on any package without `.copier-answers.yml`. Prefer `lint_action_explicit` there — it takes `AddPrecommit`/`AddLychee` as `-d` flags instead.
- **Flag the cost of `testitem_cli`.** It rewrites `test/runtests.jl` and obliges a test migration, so it is a proposal to discuss, not a quick win to bundle with the others.

## Protected files

The template's `_skip_if_exists` list decides whether an existing file is preserved or replaced; it is not a per-feature property. Of the files the features own, only `AGENTS.md` and `CHANGELOG.md` are on that list — so `agents` and `changelog` never touch an existing file, while `dependabot`, `lint_action`, `pre_commit*` and `testitem_cli` overwrite theirs. `test/runtests.jl` is an explicit exception carved out of the list's blanket protection for `**/*.jl`, which is why the test runner is replaceable at all.

Both outcomes print the same "Applied N feature(s)" line, so read the diff rather than the output. Two consequences to pass on to the user:

- A protected file never receives template improvements — not on `add-feature`, not on a later template update. Bringing an old `AGENTS.md` or `CHANGELOG.md` up to date is a manual diff against a freshly rendered copy.
- To adopt the template's version of a protected file, the user must move or delete their own first. Do that only on their explicit instruction.

## Answering template questions

- Answers are read from the package's `.copier-answers.yml` when it exists; anything unresolved must be passed as `-d KEY=VALUE` (repeatable).
- `Cannot determine required fields ...` names the missing keys and the `-d` flags to pass. Where to find the usual values: `PackageName` is `name` in `Project.toml`; `PackageOwner` is the GitHub owner in `git remote -v`; `Authors` is `authors` in `Project.toml`. Confirm anything you had to guess with the user — a wrong value applies "successfully".
- Some answers fall outside what guessing covers — notably, the `Add*` answers. Each one says **whether the package uses a given tool**, not what a particular file should contain; the feature's output follows from that. `AddPrecommit` means "this package uses pre-commit", and the `Lint.yml` job is a consequence. **Read the feature's `description` in `list-features --json` before deciding them**: it names the tool behind each answer and the config file that goes with it. Then resolve each answer in two steps:
  1. **The config file exists → the answer is true.** A package with `.pre-commit-config.yaml` already uses pre-commit, so `AddPrecommit=true`. Settle these yourself and say what you concluded.
  2. **The config file is absent → you cannot conclude anything. Ask.** Absence means the package does not use that tool *yet*, not that the user doesn't want it — turning the answer on is exactly how they'd adopt it. Ask about the tool in the user's terms ("do you want the lint workflow to check links too?"), and set the answer from their reply.

  Never pass a default for these. The CLI does no inference of its own — it resolves fields from the answers file and `-d` only — so an unasked question becomes a silently wrong file.
- Features with `requires_answers: true` refuse to run without `.copier-answers.yml` — no `-d` flag substitutes for it, because the feature's own entry doesn't list those fields in `required_fields`. `lint_action` renders `Lint.yml` from `AddPrecommit` and `AddLychee`, which record whether the package uses pre-commit and the Lychee link checker, and guessing doesn't cover them. Falling back to template defaults would produce a workflow that checks the wrong things — or nothing — while still reporting success, so the feature refuses instead. Check `list-features --json` for a `<feature>_explicit` variant first (e.g. `lint_action_explicit` takes the same answers as `-d` flags); only if none exists should you suggest `BestieTemplate.apply` (Julia) to apply the full template.
- The answers file is updated when present and never created.

## Machine-readable mode

Both commands accept `--json`. Failures print `{"error": "<message>"}` and exit 1; usage mistakes exit 2. Parse the last stdout line — copier may print warnings above it.

## Version pinning

`--ref vX.Y.Z` pins the template version; the default is the latest template release, which is what you normally want. An error saying the feature "produced none of its files" means the rendered template version predates it — pass a newer `--ref`, or `--ref main` for a feature that has not made it into a release yet.
