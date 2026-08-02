# bestie-template

Python interface to [BestieTemplate](https://github.com/JuliaBesties/BestieTemplate.jl): add template features to an existing Julia package without installing Julia.

> **Status: experimental, not yet on PyPI.**

With [uv](https://docs.astral.sh/uv/), no install step is needed:

```sh
uvx --from 'git+https://github.com/JuliaBesties/BestieTemplate.jl@main#subdirectory=python' bestie list-features
```

The two commands (`bestie --help` for all options):

```sh
bestie list-features
bestie add-feature agents,changelog path/to/MyPackage.jl -d PackageName=MyPackage
```

The same as a library:

```python
import bestie_template

bestie_template.list_features()
bestie_template.add_feature(["agents"], "path/to/MyPackage.jl", {"PackageName": "MyPackage"})
```

Both read the `features.toml` registry at the repository root — the same one the Julia `BestieTemplate.add_feature` reads, so the two stay in sync by construction.

## Development

```sh
uv sync                       # .venv with the package + dev dependencies
uv run pytest                 # unit + integration (integration runs real copier on this checkout)
uv run pytest -m "not integration"   # fast subset
uv run bestie list-features   # the CLI, against this checkout
```
