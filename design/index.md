# Design: Python interface for BestieTemplate (`bestie-template`)

Working design documents for exposing Bestie's template operations outside Julia — starting with `add_feature` — via a Python package, a CLI, an HTTP API, an MCP server, and an agent SKILL.

> **Status**: design phase. These documents are working notes, not user documentation. They may be removed or folded into the proper docs (`docs/src/`) once the implementation stabilizes.

## Motivation

Bestie's real product is `copier.yml` + `template/` — pure [Copier](https://copier.readthedocs.io) configuration that any copier client can consume. The Julia layer is thin, and its most valuable logic (the feature registry, merge order, and selective-regeneration mechanism behind `add_feature`) is portable, pure logic. A Python implementation removes a layer (PythonCall/CondaPkg) rather than adding one, and unlocks users and frontends that will never install Julia:

- `uv run --with bestie-template bestie add-feature agents,testitem_cli`
- AI agents adding features via a SKILL or MCP server ("add a dependabot file", "I want to use `@testitem`")
- A future web GUI for answering template questions

## Scope of the MVP

**Features only.** The MVP exposes `add_feature` and `list_features` — nothing else.

- No guessing (`guess.jl` stays Julia-only for now).
- No question introspection / interactive flows (frozen; see [06-decisions.md](06-decisions.md)).
- No `generate`/`apply`/`update` in the Python package yet.
- Discoverability is limited to *features* (via `features.toml` descriptions), not *questions*.

## Files

| File | Contents |
| ---- | -------- |
| [01-architecture.md](01-architecture.md) | The L0–L3 layering: copier, generic core, branding, operations, frontends |
| [02-features-toml.md](02-features-toml.md) | The `features.toml` registry: schema, semantics, migration from `src/friendly.jl` |
| [03-generic-vs-branding.md](03-generic-vs-branding.md) | The generic/branding split, its invariants, and the path to a template-agnostic tool |
| [04-frontends.md](04-frontends.md) | CLI, FastAPI, MCP (features-only), and SKILL |
| [05-releases-and-security.md](05-releases-and-security.md) | Monorepo layout, release chain, version alignment, supply-chain security |
| [06-decisions.md](06-decisions.md) | Decision log with rationale, including frozen/rejected options |

## Roadmap / TODO

1. [x] **`features.toml` at repo root** with the generic schema and `schema_version`; migrate feature definitions (including descriptions) out of `src/friendly.jl`; Julia's `_add_feature` reads the TOML (behavior-preserving — the existing `test/test-add-feature.jl` suite is the safety net).
2. [x] **Python package in `python/`**: `copier_features` (generic L1) + `bestie_template` (branding) + L2 `add_feature`/`list_features`; unit tests plus golden-dir integration tests mirroring `test/test-add-feature.jl`; CI check that the generic module never imports branding (`.github/workflows/TestPython.yml`).
3. [x] **CLI + PyPI**: typer CLI, trusted publishing (OIDC) on `py-v*` tags; `uvx` recipe in Bestie's docs. (Workflow ready; the first actual PyPI release needs the trusted-publisher + `pypi` environment configured on GitHub/PyPI, then a `py-v0.1.0` tag.)
4. [ ] **FastAPI over L2** (`bestie serve`, localhost-only) — doubles as an executable contract test for L2's schemas.
5. [ ] **MCP server (features-only) + SKILL**; add an "asking Bestie for features" section to the generated `AGENTS.md` template so every Bestie package becomes agent-upgradable.
6. [ ] **Freezer — revisit deliberately**: question introspection (pending an upstream copier discoverability conversation), guessing, webapp GUI.
7. [ ] **End-state**: Julia's `add_feature` becomes a veneer over the Python L2 once parity has held across a few release cycles.

Steps 1–3 alone deliver the `uv run --with bestie-template bestie add-feature ...` user story; 4 and 5 are each roughly a day on top of a stable L2.
