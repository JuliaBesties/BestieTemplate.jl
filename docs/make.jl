using COPIERTemplate
using Documenter

DocMeta.setdocmeta!(COPIERTemplate, :DocTestSetup, :(using COPIERTemplate); recursive = true)

const page_rename = Dict("developer.md" => "Developer docs")

function nice_name(file)
  file = replace(file, r"^[0-9]*-" => "")
  if haskey(page_rename, file)
    return page_rename[file]
  end
  return splitext(file)[1] |> x -> replace(x, "-" => " ") |> titlecase
end

makedocs(;
  modules = [COPIERTemplate],
  doctest = true,
  linkcheck = true,
  authors = "Abel Soares Siqueira <abel.s.siqueira@gmail.com> and contributors",
  repo = "https://github.com/abelsiqueira/COPIERTemplate.jl/blob/{commit}{path}#{line}",
  sitename = "COPIERTemplate.jl",
  format = Documenter.HTML(;
    prettyurls = true,
    canonical = "https://abelsiqueira.github.io/COPIERTemplate.jl",
    assets = ["assets/style.css"],
  ),
  pages = [
    "Home" => "index.md"
    [
      nice_name(file) => file for
      file in readdir(joinpath(@__DIR__, "src")) if file != "index.md" && splitext(file)[2] == ".md"
    ]
  ],
)

deploydocs(; repo = "github.com/abelsiqueira/COPIERTemplate.jl", push_preview = true)
