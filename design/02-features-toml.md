# The `features.toml` registry

A single declarative file, at the repository root, that defines every `add_feature` feature. It is the **single source of truth** consumed by both the Julia implementation (`src/friendly.jl`) and the Python package — the two can only drift if one stops reading it.

## Why a separate file, and why TOML

- **Outside `template/`**: `_subdirectory: template` in `copier.yml` means files at the repo root are never rendered into generated packages. The registry is free to live there.
- **Ours, not copier's**: the file deliberately does not extend `copier.yml`. It is a convention *on top of* copier that any copier template could adopt — that separation is the genericity story ([03-generic-vs-branding.md](03-generic-vs-branding.md)).
- **TOML over YAML**: the schema is flat (scalars, string arrays, one inline table), which is TOML's sweet spot. Julia parses it with the stdlib `TOML` (no new dependency); Python with stdlib `tomllib` (read-only, exactly right for config). Explicit `[features.<name>]` headers make every chunk self-describing (good for humans and LLMs), there is no indentation to miscount, and keys are grep-able verbatim.
- **Version pinning for free**: `add_feature` pins the template to a git ref (release tag or `HEAD`); fetching `features.toml` **at that same ref** means feature definitions always match the template version being applied. (This fixes a latent issue in the current Julia design, where the compiled-in `Val` registry can disagree with an `:online` template.)

## Schema

```toml
schema_version = 1

[features.agents]
description = "Adds AGENTS.md (an existing AGENTS.md is kept unchanged)"
forced_data = { AddAgentsMd = true }
included_files = ["AGENTS.md"]
required_fields = ["PackageName"]
requires_answers = false

[features.testitem_cli]
description = "Regenerates test/runtests.jl with the testitem_cli testing strategy"
forced_data = { TestingStrategy = "testitem_cli" }
included_files = ["test/runtests.jl"]
required_fields = []
requires_answers = false

[features.lint_action]
description = "Regenerates .github/workflows/Lint.yml"
forced_data = { AddLintCI = true }
included_files = [".github/workflows/Lint.yml"]
required_fields = []
requires_answers = true
```

Field semantics (unchanged from the current `_add_feature` tuples in `src/friendly.jl`):

| Field | Meaning |
| ----- | ------- |
| `description` | One line, user-facing. Returned by `list_features` / `GET /features` / the MCP tool; this is the discoverability surface. Migrated from the per-feature lines currently in the `add_feature` docstring. |
| `forced_data` | Answers always applied, highest priority in the merge order. |
| `included_files` | The only paths copier regenerates (everything else is excluded via `["**", "!file", ...]`). Must be gated in the template on the `forced_data` flag(s). |
| `required_fields` | Answer keys that must be resolvable (from the answers file or explicit `data`) or the operation errors. |
| `requires_answers` | If `true`, `.copier-answers.yml` must exist in the destination (the feature depends on the user's previous template choices). |

Aliases (today `pre_commit` → `pre_commit_with_config`) get their own key:

```toml
[features.pre_commit]
alias_of = "pre_commit_with_config"
```

`schema_version` is bumped on any breaking schema change; both implementations refuse versions they don't know. This is the **only hard compatibility surface** between the engine and the template (see [05-releases-and-security.md](05-releases-and-security.md)).

## Semantics the consumers must implement

These rules are behavior, not schema — they are documented here because both implementations must agree on them and they are tested on both sides:

1. **Merge order** (later wins): answers file → *(Julia only, for now: guessed data)* → explicit `data` argument → `forced_data`. The Python MVP has no guessing.
2. **Answers-file rule**: if `.copier-answers.yml` exists, include it in the regeneration (add `!.copier-answers.yml` to the excludes) so it gets updated; if it does not exist, **never create it** — `add_feature` targets packages that may not be managed by Bestie, and creating the file would be intrusive.
3. **Placeholders**: copier requires `PackageName`, `PackageOwner`, `Authors` to be answerable; when a feature's files don't reference them and they can't be resolved, fill with the string `UNUSED`.
4. **copier invocation**: `overwrite=True, defaults=True, quiet=True`, exclude list as above, `vcs_ref` from the pinned ref.

## Migration plan (roadmap step 1)

1. Create `features.toml` from the current `_add_feature` methods and the docstring descriptions in `src/friendly.jl`.
2. Make `_add_feature` (or a replacement) read the TOML — Julia stdlib `TOML`, loaded from `local_template_path` for `:local` (falling back to the bundled copy). For `:online` the Julia side keeps using the **bundled** registry for now — same behavior as the old compiled-in registry; fetching it at the pinned ref is deferred to the Python package (which needs the fetch logic anyway).
3. The `add_feature` docstring's feature list becomes generated from (or at minimum cross-checked in tests against) the TOML, so docs can't drift either.
4. Existing `test/test-add-feature.jl` passes unchanged — the migration is behavior-preserving by definition.
