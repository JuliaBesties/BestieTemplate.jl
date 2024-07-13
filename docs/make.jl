using BestieTemplate
using Documenter

DocMeta.setdocmeta!(BestieTemplate, :DocTestSetup, :(using BestieTemplate); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers

makedocs(;
  modules = [BestieTemplate],
  authors = "Abel Soares Siqueira <abel.s.siqueira@gmail.com> and contributors",
  repo = "https://github.com/abelsiqueira/BestieTemplate.jl/blob/{commit}{path}#{line}",
  sitename = "BestieTemplate.jl",
  format = Documenter.HTML(; canonical = "https://abelsiqueira.github.io/BestieTemplate.jl"),
  pages = [
    "index.md"
    [
      file for
      file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
    ]
  ],
)

deploydocs(; repo = "github.com/abelsiqueira/BestieTemplate.jl", push_preview = true)
