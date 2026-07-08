# Decision log

Decisions made during the design phase (2026-07), with rationale. Revisit deliberately, not accidentally.

## Decided

### D1 — MVP is features-only, no guessing

`add_feature` + `list_features` are the entire Python MVP. `guess.jl` (Project.toml, `docs/make.jl`, `.JuliaFormatter.toml` parsing) stays Julia-only for now; missing data is supplied explicitly via `--data`. **Why**: guessing is the only Julia-domain logic in the core path — dropping it makes the MVP almost purely *generic engine + branding + data file*, which is the split we want to preserve. Guessing can be added later as a branding-side plugin without touching the generic core.

### D2 — `features.toml` (TOML, repo root) is the single source of truth

See [02-features-toml.md](02-features-toml.md). Both Julia and Python read it; descriptions included (migrated from the `add_feature` docstring in `src/friendly.jl`). **Why TOML**: flat schema, stdlib parsers on both sides (Julia `TOML`, Python `tomllib`), self-describing `[features.<name>]` sections, no indentation ambiguity, grep-able keys.

### D3 — copier public API only

`run_copy` (later `run_update`) and nothing else; no `copier._template`, no `Worker`. Verified sufficient for the features mechanism on copier 9.14.3. **Why**: private API churn is upstream's prerogative; we expect collaboration with copier and that relationship is healthier as feature requests + prior art than as a downstream pinned to internals.

### D4 — Discoverability limited to features, not questions

The frontends expose two "sets": **features** (the curated aggregations in `features.toml` — in scope) and **questions** (the raw copier questionnaire — out of scope). `list_features` descriptions are the entire MVP discoverability surface.

### D5 — Monorepo, independent release trains

Python package in `python/`, template tags `vX.Y.Z`, Python tags `py-vX.Y.Z`, PyPI trusted publishing. See [05-releases-and-security.md](05-releases-and-security.md).

### D6 — Generic/branding split with enforced invariants

`copier_features` never imports `bestie_template` (CI-enforced); branding chooses defaults, never restricts (`--template`/`--ref` overridable everywhere, including L3). See [03-generic-vs-branding.md](03-generic-vs-branding.md).

### D7 — Frontend order: CLI → FastAPI → MCP + SKILL

CLI has the highest value/effort ratio and `uv` makes distribution trivial. FastAPI is a localhost tool and an executable contract test for L2. MCP is features-only, mirroring L2 one-to-one; SKILL covers shell-capable agents. Testability stays high because all of them are thin over the same L2.

### D8 — End-state: Julia consumes the Python package

Once parity holds across a few release cycles, `BestieTemplate.jl` (which already ships a Python runtime via CondaPkg for copier) depends on `bestie-template` and `src/friendly.jl` becomes a veneer over L2. One implementation, zero drift. Not the first step: port first, prove parity with mirrored tests, invert later.

## Frozen (decide later)

### F1 — Question introspection / interactive flows

Parsing `copier/*.yml` (or the questionnaire semantics: `when`/`default` Jinja evaluation, choices, validators) is **frozen**. It is the prerequisite for the webapp GUI and question-level MCP tools. Options when thawed: (a) implement discoverability in copier upstream (preferred — aligns with D3 and the collaboration goal); (b) parse the YAML ourselves (we own the template; `!include` is ~10 lines; guard with a CI round-trip test: defaults computed by our parser vs. a real copier run must produce identical output).

### F2 — Webapp GUI

Blocked on F1. The backend is trivial (FastAPI over L2 already exists by then); the cost is the dynamic form semantics.

### F3 — `generate` / `apply` / `update` in Python

Straightforward (same public copier surface) but out of MVP scope; add after the CLI stabilizes if demand appears.

## Rejected

### R1 — Generic tool first

Building a template-agnostic `copier-features` product before Bestie works end-to-end triples the design surface (plugin API, conventions, other templates' edge cases) with zero consumers. Be the prior art first; extraction is cheap by D6.

### R2 — Pure copier-CLI recipes as the product

copier 9.14.3's CLI can express the mechanism (`copier copy -f -d AddAgentsMd=true -x '**' -x '!AGENTS.md' ...`), which is useful as interim SKILL content, but it has no required-field validation, no answers-file discipline, and hostile ergonomics — not foolproof, so not the product.

### R3 — Separate repository for the Python package

Would reintroduce the template/registry/engine synchronization problem that the monorepo + ref-pinned `features.toml` solves.
