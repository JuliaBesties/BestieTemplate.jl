<p>
  <img src="docs/src/assets/logo-wide.png" alt="COPIERTemplate.jl">
</p>

# Copier OPInionated Evolving Reusable Template

<div align="center">

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://abelsiqueira.github.io/COPIERTemplate.jl/stable)
[![In development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://abelsiqueira.github.io/COPIERTemplate.jl/dev)
[![Lint workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Build Status](https://github.com/abelsiqueira/COPIERTemplate.jl/workflows/Test/badge.svg)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions)
[![Test workflow status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Lint workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/abelsiqueira/COPIERTemplate.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/abelsiqueira/COPIERTemplate.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/abelsiqueira/COPIERTemplate.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8350577.svg)](https://doi.org/10.5281/zenodo.8350577)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

</div>

This is

- a [copier](https://copier.readthedocs.io) template/skeleton for Julia packages (see folder [template](template)); and
- a package that wraps `copier` in Julia using `PythonCall`.

The template

- is opinionated but allows options;
- can be applied to existing packages (thanks to copier);
- is automatically reapplied through Pull Requests made by the Copier.yml workflow.

<!-- agg https://asciinema.org/a/611189 docs/src/assets/demo.gif --speed 2.5 --cols 80 --rows 20 --font-family "JuliaMono" -->
[![asciicast](docs/src/assets/demo.gif)](https://asciinema.org/a/611189)

## Quickstart

Install this package, then:

```julia-repl
julia> using COPIERTemplate
julia> COPIERTemplate.generate("YourPackage.jl")
```

Or, you can use [copier](https://copier.readthedocs.io) directly:

```bash
copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
```

If you like what you see, check the [full usage guide](@ref full_guide).

## Contributing

If you would like to get involved in the COPIERTemplate growth, please check our [contributing guide](docs/src/90-contributing.md). We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our [code of conduct](CODE_OF_CONDUCT.md).

If your interest is in developing the package, check the [development guide](docs/src/90-developer.md) as well.

## Users and Examples

The following are users and examples of repos using this template, or other templates based on it.
Feel free to create a pull request to add your repo.

- This package itself uses the template.
- [COPIERTemplateExample.jl](https://github.com/abelsiqueira/COPIERTemplateExample.jl)
