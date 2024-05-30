```@meta
CurrentModule = COPIERTemplate
```

# COPIERTemplate - Copier OPInionated Evolving Reusable Template

![COPIERTemplate.jl](assets/logo-wide.png)

Welcome to the documentation of COPIERTemplate.jl. This package provides a template in the [copier](https://copier.readthedocs.io) engine for a Julia package. Furthermore, it provides a wrapper around convenience calls to that package.

The main features of this package/template are:

- It provides a curated (opinionated) list of tools and best practices for Julia package development;
- It can be applied and reapplied to existing packages, allowing the updates in the template to be imported into the package;

## Using

To fully benefit from the template, there are some steps to be done **before** and **after** you generate your package.
Check the [full guide](@ref full_guide) for more details.

However, if you kinda know what you need to do, this is the TL;DR:

```julia-repl
julia> using COPIERTemplate
julia> COPIERTemplate.generate("YourPackage.jl")
```

Or, alternatively, using [copier](https://copier.readthedocs.io), run

```bash
copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl
```

I really recommend checking the [full guide](@ref full_guide), though.

To understand more about our motivation and what the template provides, check the [explanation page](@ref explanation).

## Getting and providing help

I hope you find this package useful. If you have any questions, requests, or comments, check the [issues](https://github.com/abelsiqueira/COPIERTemplate.jl/issues) and [discussion](https://github.com/abelsiqueira/COPIERTemplate.jl/discussions) pages.

If you would like to get involved in the COPIERTemplate growth, please check our [contributing guide](90-contributing.md). We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our [code of conduct](https://github.com/abelsiqueira/COPIERTemplate.jl/blob/main/CODE_OF_CONDUCT.md).

If your interest is in developing the package, check the [development guide](90-developer.md) as well.

## Contributors

```@raw html
<!-- markdown-link-check-disable -->

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://abelsiqueira.com"><img src="https://avatars.githubusercontent.com/u/1068752?v=4?s=100" width="100px;" alt="Abel Soares Siqueira"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href="#code-abelsiqueira" title="Code">💻</a> <a href="#projectManagement-abelsiqueira" title="Project Management">📆</a> <a href="#doc-abelsiqueira" title="Documentation">📖</a> <a href="#maintenance-abelsiqueira" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://tmigot.github.io"><img src="https://avatars.githubusercontent.com/u/25304288?v=4?s=100" width="100px;" alt="Tangi Migot"/><br /><sub><b>Tangi Migot</b></sub></a><br /><a href="#code-tmigot" title="Code">💻</a> <a href="#doc-tmigot" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://pabrod.github.io/"><img src="https://avatars.githubusercontent.com/u/7677614?v=4?s=100" width="100px;" alt="Pablo Rodríguez-Sánchez"/><br /><sub><b>Pablo Rodríguez-Sánchez</b></sub></a><br /><a href="#doc-PabRod" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.esciencecenter.nl/"><img src="https://avatars.githubusercontent.com/u/15750539?v=4?s=100" width="100px;" alt="Olga Lyashevska"/><br /><sub><b>Olga Lyashevska</b></sub></a><br /><a href="#code-lyashevska" title="Code">💻</a> <a href="#doc-lyashevska" title="Documentation">📖</a> <a href="#ideas-lyashevska" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://luisaforozco.github.io/"><img src="https://avatars.githubusercontent.com/u/99738896?v=4?s=100" width="100px;" alt="Luisa Orozco"/><br /><sub><b>Luisa Orozco</b></sub></a><br /><a href="#code-luisaforozco" title="Code">💻</a> <a href="#doc-luisaforozco" title="Documentation">📖</a> <a href="#ideas-luisaforozco" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://esciencecenter.nl"><img src="https://avatars.githubusercontent.com/u/1705862?v=4?s=100" width="100px;" alt="Netherlands eScience Center"/><br /><sub><b>Netherlands eScience Center</b></sub></a><br /><a href="#financial-nlesc" title="Financial">💵</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/suvayu"><img src="https://avatars.githubusercontent.com/u/229540?v=4?s=100" width="100px;" alt="Suvayu Ali"/><br /><sub><b>Suvayu Ali</b></sub></a><br /><a href="#bug-suvayu" title="Bug reports">🐛</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sverhoeven"><img src="https://avatars.githubusercontent.com/u/1713488?v=4?s=100" width="100px;" alt="Stefan Verhoeven"/><br /><sub><b>Stefan Verhoeven</b></sub></a><br /><a href="#code-sverhoeven" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

```
