# Architecture: the L0–L3 layering

Every frontend consumes the same two lower layers; the layers only ever call downward. The generic core (L1) has zero Bestie knowledge; branding (L1½) is data and defaults, not logic.

```text
L3  frontends      CLI (typer)   FastAPI (`bestie serve`)   MCP (fastmcp)   SKILL (docs only)
                        \              |                       /
L2  operations      add_feature(...) -> AddFeatureResult,  list_features(...) -> list[Feature]
                        |
L1½ branding        bestie_template: template URL, ref policy, messages, re-exports with defaults
L1  generic core    copier_features: features.toml loading, merge order, exclude list, validation
                        |
L0  copier          copier.run_copy(...)  (public API only)
```

## L0 — copier (external dependency)

PyPI `copier`, pinned `>=9.14,<10`. For the features MVP the entire surface is **one public function**:

```python
copier.run_copy(src, dst, data, exclude=[...], overwrite=True, defaults=True, quiet=True, vcs_ref=...)
```

copier owns: cloning the template at the pinned ref, Jinja rendering, question validators (it validates supplied `data` even with `defaults=True`), and writing `.copier-answers.yml`.

Rules:

- **Public API only.** No `copier._template`, no `Worker`. Anything we need beyond the public surface (e.g. question discoverability) is an upstream feature request / collaboration, never a reach into privates. (Verified on copier 9.14.3: `run_copy`/`run_update`/`run_recopy` are the public entry points; `Template`/`Worker` are underscore-private since ~9.5.)
- CI runs against the pinned floor **and** a canary job against copier's latest release, as the tripwire for behavior drift.
- copier exceptions are wrapped into typed errors at L1; frontends never see raw tracebacks.

## L1 — generic core (`copier_features`)

Pure Python, stdlib-first: `tomllib` for the registry, `dataclasses` for the `Feature` model, `pyyaml` only for reading `.copier-answers.yml` (copier's format, unavoidable). No printing, no network beyond fetching `features.toml`, no Bestie knowledge — template URL, feature names, and messages all arrive as arguments.

Responsibilities:

- Load and validate `features.toml` (see [02-features-toml.md](02-features-toml.md)) from a local path or fetched at the template ref (raw-URL fetch with a bundled fallback).
- Build the copier exclude list: `["**", "!<file>", ...]` for the feature's `included_files`, plus `!.copier-answers.yml` **only if** the answers file already exists (update it, never create it — Bestie may be applied to packages it didn't generate).
- Apply the MVP merge order (later wins): **answers file → explicit `data` → `forced_data`**. No guessing in the MVP.
- Check `required_fields`; inject `UNUSED` placeholders for copier-required fields the feature's files don't reference (`PackageName`, `PackageOwner`, `Authors`).
- Map copier exceptions to typed errors.

This is where ~90% of unit tests live, and none of them need copier or the network.

## L1½ — branding (`bestie_template`)

Small by design: the template URL (`https://github.com/JuliaBesties/BestieTemplate.jl`), the ref policy (default to latest release; `HEAD` on request), user-facing message strings, and re-exports of L2 with Bestie defaults baked in.

Ships in the **same PyPI distribution** as the generic module for now — one wheel, two top-level packages — under the invariants in [03-generic-vs-branding.md](03-generic-vs-branding.md) (`copier_features` never imports `bestie_template`; branding chooses defaults, never restricts).

## L2 — operations

One function per user-visible verb. The MVP is exactly two:

```python
add_feature(features: list[str], dst: Path, data: dict | None = None,
            ref: str | None = None, template: str | None = None) -> AddFeatureResult
list_features(ref: str | None = None, template: str | None = None) -> list[Feature]
```

- Each composes L1 pieces plus **at most one** L0 call.
- No printing. Returns structured results (features applied, files targeted, template ref used, whether the answers file was updated) — presentation is the frontends' job.
- `template` and `ref` are always overridable; branding only supplies defaults. This is what makes the frontends work with forks, local checkouts, and other templates adopting the `features.toml` convention.
- **These signatures are the public contract**: semver applies here, the FastAPI schemas mirror them, and the future Julia veneer calls them.
- Integration tests live here: golden-directory tests running real copier against a temp dir, mirroring the expectations of the Julia `test/test-add-feature.jl` suite so both implementations are held to identical behavior.

## L3 — frontends

Thin transports over L2 — each should stay under ~150 lines precisely because L2 already returns structured results. Details in [04-frontends.md](04-frontends.md).

## What stays in Julia (for now)

`generate`, `apply`, `update`, guessing (`guess.jl`), `new_pkg_quick`, and all interactive flows remain Julia-only. The end-state (roadmap step 7) inverts the dependency: `BestieTemplate.jl` already ships a Python runtime via CondaPkg for copier, so it can depend on the `bestie-template` package instead and reduce `src/friendly.jl` to a veneer over L2 — one implementation, zero drift.
