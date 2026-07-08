# Frontends

All frontends are thin transports over the L2 operations (`add_feature`, `list_features`). Each should stay under ~150 lines, precisely because L2 returns structured results and does no printing. All of them expose `--template`/`--ref` overrides (branding chooses defaults, never restricts).

## CLI (`bestie`)

- **Stack**: [typer](https://typer.tiangolo.com). Entry point `bestie` in the `bestie-template` distribution.
- **Commands (MVP)**:
  - `bestie add-feature agents,testitem_cli [--data K=V ...] [--ref TAG] [--template URL] [PATH]` — features applied in order, like sequential `add_feature` calls in Julia.
  - `bestie list-features [--json] [--ref TAG] [--template URL]` — names + descriptions from `features.toml`; `--json` for scripting/agents.
- **Distribution**: PyPI, so both invocations work cold on a machine with only `uv`:

  ```sh
  uv run --with bestie-template bestie add-feature agents,testitem_cli
  uvx --from bestie-template bestie list-features
  ```

- **Errors**: typed L1/L2 errors rendered as short human messages + non-zero exit; `--json` mode emits machine-readable errors.

## HTTP API (`bestie serve`)

- **Stack**: FastAPI + uvicorn, launched as `bestie serve` (extra dependency group, e.g. `bestie-template[serve]`).
- **Endpoints (MVP)**: `GET /features` and `POST /add-feature`, with pydantic schemas generated from the L2 result dataclasses — the API doubles as an executable contract test for L2's shapes.
- **Security posture**: this process writes to local paths. It binds to loopback only, is documented as a *local tool* (backend for a future localhost webapp GUI), and is explicitly **not a deployable service**. Binding beyond loopback is out of scope until there is an authentication story.

## MCP server (features-only)

- **Stack**: fastmcp over stdio; launchable as `uvx --from bestie-template bestie-mcp`, so agent configs need one line and no install step.
- **Tools (MVP)**: exactly two, mirroring L2 one-to-one:
  - `list_features(ref?, template?)` → names + descriptions (the discoverability surface for "what can Bestie add?").
  - `add_feature(features, dst, data?, ref?, template?)` → the structured `AddFeatureResult`.
- **Extension rule**: tool names and schemas stay direct mirrors of L2 signatures, so future capabilities (questions, whats-new, update) arrive as *new tools* rather than changes to existing ones — existing agent integrations never break.

## SKILL (documentation, no code)

A markdown skill teaching agents the CLI directly — for agents with shell access, a good CLI plus a SKILL is cheaper and easier to keep current than MCP:

- The `uvx`/`uv run` incantations above, with `--json` outputs.
- The failure modes and their fixes: missing `required_fields` (pass `--data K=V`), `requires_answers` features on packages without `.copier-answers.yml` (run `BestieTemplate.apply` first), answers file updated only when present.
- **Synergy**: Bestie already generates `AGENTS.md` into user packages (`add_feature(:agents)`). That template gains a short "asking Bestie for features" section, making every generated package self-upgradable by any agent — the SKILL content ships inside the product.

MCP still matters for shell-less contexts (claude.ai web, restricted IDEs); the SKILL covers everything else.
