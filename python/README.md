# bestie-template

Python interface to [BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl): add template features to Julia packages without installing Julia.

> **Status: early development, not yet on PyPI.** The library API (`add_feature`, `list_features`) is functional; the CLI, HTTP API, and MCP server are planned. See `../design/index.md` for the roadmap.

```python
import bestie_template

bestie_template.list_features()          # what can be added
bestie_template.add_feature(["agents", "testitem_cli"], "path/to/MyPackage.jl")
```

The package has two layers (see `../design/03-generic-vs-branding.md`):

- `copier_features` — a template-agnostic engine: any [copier](https://copier.readthedocs.io) template that ships a `features.toml` registry at its repository root can be feature-sliced with it. It never references Bestie.
- `bestie_template` — Bestie's defaults on top: template URL, registry resolution, placeholder fields. Every default is overridable (`template=`, `ref=`).

## Development

```sh
uv sync          # create .venv with the package + dev dependencies
uv run pytest    # unit + integration tests (integration runs real copier on the local checkout)
```
