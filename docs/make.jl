using COPIERTemplate
using Documenter

DocMeta.setdocmeta!(COPIERTemplate, :DocTestSetup, :(using COPIERTemplate); recursive = true)

makedocs(;
  modules = [COPIERTemplate],
  doctest = true,
  linkcheck = true,
  authors = "Abel Soares Siqueira <abel.s.siqueira@gmail.com> and contributors",
  repo = "https://github.com/abelsiqueira/COPIERTemplate.jl/blob/{commit}{path}#{line}",
  sitename = "COPIERTemplate.jl",
  format = Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://abelsiqueira.github.io/COPIERTemplate.jl",
    assets = ["assets/style.css"],
  ),
  pages = [
    "Home" => "index.md",
    "Contributing" => "contributing.md",
    "Dev setup" => "developer.md",
    "Reference" => "reference.md",
  ],
)

deploydocs(; repo = "github.com/abelsiqueira/COPIERTemplate.jl", push_preview = true)
