<p align="center">
  <img src="docs/src/assets/logo.png" alt="BestieTemplate.jl">
</p>

# BestieTemplate.jl

Your best practices friend.

<div align="center">

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaBesties.github.io/BestieTemplate.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaBesties.github.io/BestieTemplate.jl/dev)
[![Test workflow status](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaBesties/BestieTemplate.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaBesties/BestieTemplate.jl)
[![Lint workflow Status](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/JuliaBesties/BestieTemplate.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8350577.svg)](https://doi.org/10.5281/zenodo.8350577)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![All Contributors](https://img.shields.io/github/all-contributors/JuliaBesties/BestieTemplate.jl?labelColor=5e1ec7&color=c0ffee&style=flat-square)](#contributors)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

</div>

## What does `BestieTemplate` do?

Creating `Julia` packages involve the creation and edition of many tiny files.
Wouldn't it be great to automate this?

This is exactly what `BestieTemplate` does.

### FAQ

- How is `BestieTemplate` different from `PkgTemplates`?
  - it can be applied to existing packages
  - it invites to follow some (opinionated) best practices
  - it can be reapplied to acquire updates made to the template
  - it is automatically reapplied through Pull Requests made by the `Copier.yml` workflow (Work in progress)

### Architecture

Under the hood, `BestieTemplate` is no more and no less than:

- a [copier](https://copier.readthedocs.io) template/skeleton for Julia packages (see folder [template](template)); and
- a package that wraps `copier` in Julia using `PythonCall` with some convenience functions.

## Quickstart

Install `BestieTemplate` in your chosen environment (we recommend globally) by entering `pkg` mode by pressing `]` and then:

```julia-repl
julia> # press ]
pkg> add BestieTemplate
```

then:

```julia-repl
julia> using BestieTemplate
julia> BestieTemplate.generate("path/to/YourNewPackage.jl")
julia> # or BestieTemplate.apply("path/to/YourExistingPackage.jl")
```

please note that `"YourPackage.jl"` can either be a fresh new package or an existing one.

<!-- agg https://asciinema.org/a/... docs/src/assets/demo.gif --speed 2.5 --cols 80 --rows 20 --font-family "JuliaMono" -->
[![asciicast](docs/src/assets/demo.gif)](https://asciinema.org/a/611189)

If you like what you see, check the [full usage guide](https://JuliaBesties.github.io/BestieTemplate.jl/stable/10-full-guide/).

## Users and Examples

The following are users and examples of repos using this template, or other templates based on it.
Feel free to create a pull request to add your repo.

- This package itself uses the template.
- [TulipaIO.jl](https://github.com/TulipaEnergy/TulipaIO.jl)

## Contributing

If you would like to get involved in the BestieTemplate growth, please check our [contributing guide](docs/src/90-contributing.md). We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our [code of conduct](CODE_OF_CONDUCT.md).

If your interest is in developing the package, check the [development guide](docs/src/91-developer.md) as well.

### AI Coding Assistant Attribution

We use and accepts pull requests with AI coding assistants to help with development, but we expect the committers to understand and be responsible for the code that they introduce.
All commits that receive AI assistance should be signed off with:

```plaintextt
Co-authored-by: MODEL NAME (FULL MODEL VERSION) <EMAIL>
```

For example:

```plaintextt
Co-authored-by: Claude Code (claude-sonnet-4-20250514) <noreply@anthropic.com>
```

## References

Here is a list of links/repos that include content that we have used for inspiration, or used directly.
This is most likely not a complete list, since many of the things included here were based on existing packages and knowledge that we brought from other projects.
This also doesn't explain where each file came from or why they are here. You can find some of that information in the [Explanation](https://JuliaBesties.github.io/BestieTemplate.jl/stable/20-explanation/) section of the docs.

- [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl), naturally. We used it for many years, and in particular for the initial TulipaEnergyModel.jl commit (see below).
- [Netherlands eScience Center's python template](https://github.com/NLeSC/python-template) includes many of the best practices that we apply here. We used many of the ideas there in a Julia context, and took many non-Julia specific ideas from there.
- [TulipaEnergyModel.jl](https://github.com/TulipaEnergy/TulipaEnergyModel.jl) was the project that motivated this version of a template. From the start we decide to implement many best practices and so we started from a PkgTemplates.jl template and started adding parts of the python template that made sense.
- The [Julia Smooth Optimizers](https://jso.dev) package ecosystem was one of the main motivations to look for a solution that could be applied and reapplied to existing packages, in particular to help maintainers.

### Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://abelsiqueira.com"><img src="https://avatars.githubusercontent.com/u/1068752?v=4?s=100" width="100px;" alt="Abel Soares Siqueira"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href="#code-abelsiqueira" title="Code">💻</a> <a href="#projectManagement-abelsiqueira" title="Project Management">📆</a> <a href="#doc-abelsiqueira" title="Documentation">📖</a> <a href="#maintenance-abelsiqueira" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://tmigot.github.io"><img src="https://avatars.githubusercontent.com/u/25304288?v=4?s=100" width="100px;" alt="Tangi Migot"/><br /><sub><b>Tangi Migot</b></sub></a><br /><a href="#code-tmigot" title="Code">💻</a> <a href="#doc-tmigot" title="Documentation">📖</a> <a href="#review-tmigot" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://pabrod.github.io/"><img src="https://avatars.githubusercontent.com/u/7677614?v=4?s=100" width="100px;" alt="Pablo Rodríguez-Sánchez"/><br /><sub><b>Pablo Rodríguez-Sánchez</b></sub></a><br /><a href="#doc-PabRod" title="Documentation">📖</a> <a href="#ideas-PabRod" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.esciencecenter.nl/"><img src="https://avatars.githubusercontent.com/u/15750539?v=4?s=100" width="100px;" alt="Olga Lyashevska"/><br /><sub><b>Olga Lyashevska</b></sub></a><br /><a href="#code-lyashevska" title="Code">💻</a> <a href="#doc-lyashevska" title="Documentation">📖</a> <a href="#ideas-lyashevska" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://luisaforozco.github.io/"><img src="https://avatars.githubusercontent.com/u/99738896?v=4?s=100" width="100px;" alt="Luisa Orozco"/><br /><sub><b>Luisa Orozco</b></sub></a><br /><a href="#code-luisaforozco" title="Code">💻</a> <a href="#doc-luisaforozco" title="Documentation">📖</a> <a href="#ideas-luisaforozco" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://esciencecenter.nl"><img src="https://avatars.githubusercontent.com/u/1705862?v=4?s=100" width="100px;" alt="Netherlands eScience Center"/><br /><sub><b>Netherlands eScience Center</b></sub></a><br /><a href="#financial-nlesc" title="Financial">💵</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/suvayu"><img src="https://avatars.githubusercontent.com/u/229540?v=4?s=100" width="100px;" alt="Suvayu Ali"/><br /><sub><b>Suvayu Ali</b></sub></a><br /><a href="#bug-suvayu" title="Bug reports">🐛</a> <a href="#review-suvayu" title="Reviewed Pull Requests">👀</a> <a href="#code-suvayu" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sverhoeven"><img src="https://avatars.githubusercontent.com/u/1713488?v=4?s=100" width="100px;" alt="Stefan Verhoeven"/><br /><sub><b>Stefan Verhoeven</b></sub></a><br /><a href="#code-sverhoeven" title="Code">💻</a> <a href="#ideas-sverhoeven" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://dpo.github.io"><img src="https://avatars.githubusercontent.com/u/38760?v=4?s=100" width="100px;" alt="Dominique"/><br /><sub><b>Dominique</b></sub></a><br /><a href="#ideas-dpo" title="Ideas, Planning, & Feedback">🤔</a> <a href="#code-dpo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fdiblen"><img src="https://avatars.githubusercontent.com/u/144492?v=4?s=100" width="100px;" alt="fdiblen"/><br /><sub><b>fdiblen</b></sub></a><br /><a href="#code-fdiblen" title="Code">💻</a> <a href="#review-fdiblen" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/greg-neustroev"><img src="https://avatars.githubusercontent.com/u/32451432?v=4?s=100" width="100px;" alt="Greg Neustroev"/><br /><sub><b>Greg Neustroev</b></sub></a><br /><a href="#code-greg-neustroev" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lucaferranti"><img src="https://avatars.githubusercontent.com/u/49938764?v=4?s=100" width="100px;" alt="Luca Ferranti"/><br /><sub><b>Luca Ferranti</b></sub></a><br /><a href="#ideas-lucaferranti" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://gdalle.github.io/"><img src="https://avatars.githubusercontent.com/u/22795598?v=4?s=100" width="100px;" alt="Guillaume Dalle"/><br /><sub><b>Guillaume Dalle</b></sub></a><br /><a href="#ideas-gdalle" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://jhidding.github.io/"><img src="https://avatars.githubusercontent.com/u/3082555?v=4?s=100" width="100px;" alt="Johannes Hidding"/><br /><sub><b>Johannes Hidding</b></sub></a><br /><a href="#bug-jhidding" title="Bug reports">🐛</a> <a href="#review-jhidding" title="Reviewed Pull Requests">👀</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.oxinabox.net/"><img src="https://avatars.githubusercontent.com/u/5127634?v=4?s=100" width="100px;" alt="Frames White"/><br /><sub><b>Frames White</b></sub></a><br /><a href="#code-oxinabox" title="Code">💻</a> <a href="#bug-oxinabox" title="Bug reports">🐛</a> <a href="#ideas-oxinabox" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/clizbe"><img src="https://avatars.githubusercontent.com/u/11889283?v=4?s=100" width="100px;" alt="Lauren Clisby"/><br /><sub><b>Lauren Clisby</b></sub></a><br /><a href="#ideas-clizbe" title="Ideas, Planning, & Feedback">🤔</a> <a href="#code-clizbe" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/datejada"><img src="https://avatars.githubusercontent.com/u/12887482?v=4?s=100" width="100px;" alt="Diego Alejandro Tejada Arango"/><br /><sub><b>Diego Alejandro Tejada Arango</b></sub></a><br /><a href="#ideas-datejada" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hz-xiaxz"><img src="https://avatars.githubusercontent.com/u/114814844?v=4?s=100" width="100px;" alt="LeoXia"/><br /><sub><b>LeoXia</b></sub></a><br /><a href="#code-hz-xiaxz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/langestefan"><img src="https://avatars.githubusercontent.com/u/37669773?v=4?s=100" width="100px;" alt="Stefan de Lange"/><br /><sub><b>Stefan de Lange</b></sub></a><br /><a href="#code-langestefan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mmikhasenko"><img src="https://avatars.githubusercontent.com/u/22725744?v=4?s=100" width="100px;" alt="Misha Mikhasenko"/><br /><sub><b>Misha Mikhasenko</b></sub></a><br /><a href="#code-mmikhasenko" title="Code">💻</a> <a href="#doc-mmikhasenko" title="Documentation">📖</a> <a href="#bug-mmikhasenko" title="Bug reports">🐛</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
