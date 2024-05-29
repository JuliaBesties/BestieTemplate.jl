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
[![All Contributors](https://img.shields.io/github/all-contributors/abelsiqueira/COPIERTemplate.jl?labelColor=5e1ec7&color=c0ffee&style=flat-square)](#contributors)

</div>

## What does `COPIERTemplate` do?
Creating `Julia` packages involve the creation and edition of many tiny files.
Wouldn't it be great to automate this?

This is exactly what `COPIERTemplate` does.

### FAQ

- How is `COPIERTemplate` different from `PkgTemplates`?
   - it can be applied to existing packages
   - it invites to follow some (opinionated) best practices
   - it is automatically reapplied through Pull Requests made by the `Copier.yml` workflow

### Architecture
Under the hood, `COPIERTemplate` is no more and no less than:

- a [copier](https://copier.readthedocs.io) template/skeleton for Julia packages (see folder [template](template)); and
- a package that wraps `copier` in Julia using `PythonCall`.

## Quickstart

Install `COPIERTemplate` in your chosen environment (we recommend base):

```julia-repl
julia> add COPIERTemplate
```

then:

```julia-repl
julia> using COPIERTemplate
julia> COPIERTemplate.generate("YourPackage.jl")
```

please note that `"YourPackage.jl"` can either be a fresh new package or an existing one.

### Using `copier` (optional and advanced)

If you prefer to use Python's [copier](https://copier.readthedocs.io), you can create your new package directly:

```bash
copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
```

<!-- agg https://asciinema.org/a/611189 docs/src/assets/demo.gif --speed 2.5 --cols 80 --rows 20 --font-family "JuliaMono" -->
[![asciicast](docs/src/assets/demo.gif)](https://asciinema.org/a/611189)

If you like what you see, check the [full usage guide]().

## Users and Examples

The following are users and examples of repos using this template, or other templates based on it.
Feel free to create a pull request to add your repo.

- This package itself uses the template.
- [COPIERTemplateExample.jl](https://github.com/abelsiqueira/COPIERTemplateExample.jl)

## Contributing

If you would like to get involved in the COPIERTemplate growth, please check our [contributing guide](docs/src/90-contributing.md). We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our [code of conduct](CODE_OF_CONDUCT.md).

If your interest is in developing the package, check the [development guide](docs/src/90-developer.md) as well.

### Contributors
<!-- markdown-link-check-disable -->

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://abelsiqueira.com"><img src="https://avatars.githubusercontent.com/u/1068752?v=4?s=100" width="100px;" alt="Abel Soares Siqueira"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href="#code-abelsiqueira" title="Code">💻</a> <a href="#projectManagement-abelsiqueira" title="Project Management">📆</a> <a href="#doc-abelsiqueira" title="Documentation">📖</a> <a href="#maintenance-abelsiqueira" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://tmigot.github.io"><img src="https://avatars.githubusercontent.com/u/25304288?v=4?s=100" width="100px;" alt="Tangi Migot"/><br /><sub><b>Tangi Migot</b></sub></a><br /><a href="#code-tmigot" title="Code">💻</a> <a href="#doc-tmigot" title="Documentation">📖</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
