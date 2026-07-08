# Generic core vs. Bestie branding

The selective-regeneration mechanism behind `add_feature` — exclude everything except a feature's files, force its flags, run copier with defaults — is **100% template-agnostic**. Nothing about it knows Julia or Bestie. The Bestie-specific parts are exactly: the template URL, the ref policy, the message strings, and (outside the MVP) the guessers. The MVP is therefore mostly *generic engine + branding + data file*, and this split must not be lost as the code grows.

## The two packages

One PyPI distribution (`bestie-template`), two top-level packages:

| Package | Role | Knows about |
| ------- | ---- | ----------- |
| `copier_features` | Generic L1 engine: `features.toml` loading/validation, merge order, exclude-list construction, required-field checks, typed errors | copier, the `features.toml` convention |
| `bestie_template` | Branding + L2 with Bestie defaults: template URL, ref policy, messages, CLI/API/MCP entry points | `copier_features`, Bestie |

## Invariants (enforced, not aspirational)

1. **`copier_features` never imports `bestie_template`.** Enforced by a trivial CI check (import-linter or a grep test). The generic package must remain publishable on its own the day extraction is warranted — a file move, not a refactor.
2. **Branding chooses defaults, never restricts.** Every L2 operation and every frontend accepts `--template <url-or-path>` and `--ref`; `bestie_template` only fills in the defaults. This is what makes the tooling usable with forks, local checkouts, and any other copier template that adopts the `features.toml` convention.
3. **No Bestie strings in generic errors.** Typed errors in `copier_features` speak in terms of features, files, and answers; branding may wrap them with friendlier text.

## Future directions (explicitly not now)

- **Extraction**: if another template adopts the convention, `copier_features` graduates to its own PyPI package. Because of invariant 1 this is cheap; doing it *before* there is a second consumer would be premature (see [06-decisions.md](06-decisions.md)).
- **Upstreaming**: the exclude-trick "partial copy" and a features convention could become a copier feature request. We expect collaboration with copier upstream — the strategy is to be the prior art first, then propose. Never rely on copier private API in the meantime.
