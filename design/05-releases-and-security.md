# Releases, versioning, and security

This is the highest-risk operational area of the project: a monorepo now carries a Julia package, a copier template, and a Python package, and releases must chain without blocking each other.

## Monorepo layout

```text
BestieTemplate.jl/
├── Project.toml          # Julia package (root, unchanged)
├── copier.yml            # template entry point (unchanged)
├── copier/               # question files (unchanged)
├── template/             # Jinja template (unchanged)
├── features.toml         # NEW: feature registry (single source of truth)
├── python/               # NEW: Python distribution `bestie-template`
│   ├── pyproject.toml
│   ├── src/copier_features/    # generic L1
│   ├── src/bestie_template/    # branding + L2 + frontends
│   └── tests/
└── design/               # these documents
```

Why monorepo: the template source *is* this repo's URL, so one git ref pins template + `features.toml` + Julia code consistently. A separate Python repo would reintroduce exactly the synchronization problem `features.toml` solves. Files outside `template/` are never rendered into generated packages (`_subdirectory: template`), so the additions are invisible to users of the template itself.

## Version alignment

The features-only scope defuses most of the alignment problem:

- The Python package is a **version-agnostic engine**; `features.toml` is **data that travels with the template ref**. When `add_feature` pins the template to a tag and fetches the registry at that same ref, an old engine applying a new template (or vice versa) still behaves consistently.
- The only hard compatibility surface is the `features.toml` schema, guarded by `schema_version`: both implementations refuse versions they don't know, and an old engine meeting a newer schema fails with "upgrade bestie-template" instead of misbehaving.
- Consequence: the two release trains are **independent**. Template/Julia releases keep their existing `vX.Y.Z` tag flow (which also freezes `features.toml` at that ref). Python releases are less frequent and use a separate tag namespace, `py-vX.Y.Z`, so neither train blocks the other.

## Release chain

1. **Template/Julia release** (existing flow): tag `vX.Y.Z` via JuliaRegistries; nothing new, except the tag now also pins `features.toml`.
2. **Python release**: tag `py-vX.Y.Z` → GitHub Actions workflow builds the wheel from `python/` and publishes to PyPI.

## Supply-chain security

- **PyPI trusted publishing** (OIDC): no long-lived PyPI tokens in the repo. The publish workflow is authorized via GitHub's OIDC identity, scoped to this repo, the specific workflow file, and a dedicated GitHub *environment* restricted to `py-v*` tags with required reviewers.
- **Registry fetch**: `features.toml` is fetched over HTTPS at a pinned ref (raw.githubusercontent.com), with a bundled copy in the wheel as fallback. No execution — it is parsed as data by `tomllib`, never evaluated.
- **What the tool executes**: copier renders Jinja templates from the pinned ref. This is the same trust decision users already make when running copier against the template; pinning to release tags (the default ref policy) rather than `HEAD` keeps that surface reviewable. Copier extensions/tasks are not used by this template and adopting them would need a security review.
- **Dependency posture**: L1 is stdlib + `pyyaml`. typer is a core dependency — the headline `uvx --from bestie-template bestie ...` story requires the CLI in the base install — while fastapi / fastmcp stay behind optional dependency groups so the core install stays small. copier is pinned `>=9.14,<10` with a CI canary against latest.
- **HTTP API**: loopback-only local tool, not a deployable service ([04-frontends.md](04-frontends.md)).
