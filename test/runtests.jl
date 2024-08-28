# Can't use mktempdir on GitHub actions willy nilly (at least on Mac)
if get(ENV, "CI", "nothing") == "nothing"
  # This is only useful for testing offline. It creates a local env to avoid redownloading things.
  ENV["JULIA_CONDAPKG_ENV"] = joinpath(@__DIR__, "conda-env")
  if isdir(ENV["JULIA_CONDAPKG_ENV"])
    ENV["JULIA_CONDAPKG_OFFLINE"] = true
  end
end

# This is a hack because Windows managed to dirty the repo.
if get(ENV, "CI", "nothing") == "true" && Sys.iswindows()
  run(`git reset --hard HEAD`)
end

using BestieTemplate
using Logging
using Pkg
using PythonCall
using Test
using YAML

include("utils.jl")

# Defined in utils.jl to hold constants
using .C: C

test_files = filter(file -> startswith("test-")(file) && endswith(".jl")(file), readdir(@__DIR__))
for file in test_files
  title = splitext(file)[1] |> x -> replace(x, "-" => " ") |> titlecase
  @testset "$title" begin
    include(file)
  end
end
