```@meta
CurrentModule = BestieTemplate
```

# BestieTemplate - Your best practices friend

![BestieTemplate.jl](assets/logo.png)

Welcome to the documentation of BestieTemplate.jl. This package provides a template in the [copier](https://copier.readthedocs.io) engine for a Julia package. Furthermore, it provides a wrapper around convenience calls to that package.

The main features of this package/template are:

- It provides a curated (opinionated) list of tools and best practices for Julia package development;
- It can be applied and reapplied to existing packages, allowing the updates in the template to be imported into the package;

[![asciicast](assets/demo.gif)](https://asciinema.org/a/611189)

## Using

To fully benefit from the template, there are some steps to be done **before** and **after** you generate your package.
Check the [full guide](@ref full_guide) for more details.

However, if you kinda know what you need to do, this is the TL;DR:

```julia-repl
using> # press ]
pkg> add BestieTemplate
julia> using BestieTemplate
julia> BestieTemplate.generate("path/to/YourNewPackage.jl")
julia> # or BestieTemplate.apply("path/to/YourExistingPackage.jl")
```

I really recommend checking the [full guide](@ref full_guide), though.

To understand more about our motivation and what the template provides, check the [explanation page](@ref explanation).

## Getting and providing help

I hope you find this package useful. If you have any questions, requests, or comments, check the [issues](https://github.com/abelsiqueira/BestieTemplate.jl/issues) and [discussion](https://github.com/abelsiqueira/BestieTemplate.jl/discussions) pages.

If you would like to get involved in the BestieTemplate growth, please check our [contributing guide](90-contributing.md). We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our [code of conduct](https://github.com/abelsiqueira/BestieTemplate.jl/blob/main/CODE_OF_CONDUCT.md).

If your interest is in developing the package, check the [development guide](91-developer.md) as well.

## References

Here is a list of links/repos that include content that we have used for inspiration, or used directly.
This is most likely not a complete list, since many of the things included here were based on existing packages and knowledge that we brought from other projects.
This also doesn't explain where each file came from or why they are here. You can find some of that information in the [Explanation](https://abelsiqueira.com/BestieTemplate.jl/stable/20-explanation/) section of the docs.

- [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl), naturally. We used it for many years, and in particular for the initial TulipaEnergyModel.jl commit (see below).
- [Netherlands eScience Center's python template](https://github.com/NLeSC/python-template) includes many of the best practices that we apply here. We used many of the ideas there in a Julia context, and took many non-Julia specific ideas from there.
- [TulipaEnergyModel.jl](https://github.com/TulipaEnergy/TulipaEnergyModel.jl) was the project that motivated this version of a template. From the start we decide to implement many best practices and so we started from a PkgTemplates.jl template and started adding parts of the python template that made sense.
- The [Julia Smooth Optimizers](https://jso.dev) package ecosystem was one of the main motivations to look for a solution that could be applied and reapplied to existing packages, in particular to help maintainers.

## Contributors

```@raw html

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
      <td align="center" valign="top" width="14.28%"><a href="https://jhidding.github.io/"><img src="https://avatars.githubusercontent.com/u/3082555?v=4?s=100" width="100px;" alt="Johannes Hidding"/><br /><sub><b>Johannes Hidding</b></sub></a><br /><a href="#bug-jhidding" title="Bug reports">🐛</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/thanks"><img src="https://avatars.githubusercontent.com/u/1121545?v=4?s=100" width="100px;" alt="Thanks"/><br /><sub><b>Thanks</b></sub></a><br /><a href="#review-Thanks" title="Reviewed Pull Requests">👀</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

```
