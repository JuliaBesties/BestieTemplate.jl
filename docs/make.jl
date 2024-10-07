using BestieTemplate
using Documenter

DocMeta.setdocmeta!(BestieTemplate, :DocTestSetup, :(using BestieTemplate); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs") # Without the numbers
const numbered_pages = [
  file for
  file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
]

makedocs(;
  modules = [BestieTemplate],
  authors = "Abel Soares Siqueira <abel.s.siqueira@gmail.com> and contributors",
  repo = "https://github.com/JuliaBesties/BestieTemplate.jl/blob/{commit}{path}#{line}",
  sitename = "BestieTemplate.jl",
  format = Documenter.HTML(; canonical = "https://JuliaBesties.github.io/BestieTemplate.jl"),
  pages = ["index.md"; numbered_pages],
)

deploydocs(; repo = "github.com/JuliaBesties/BestieTemplate.jl")
