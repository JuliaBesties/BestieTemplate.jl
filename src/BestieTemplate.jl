"""
# BestieTemplate.jl

This package defines a copier template for Julia packages and a basic user interface around copier
to use it from Julia.

The main functions are: [`generate`](@ref), [`apply`](@ref), and [`update`](@ref).

Check the documentation: https://abelsiqueira.com/BestieTemplate.jl
"""
module BestieTemplate

using Markdown: @md_str
using TOML: TOML
using YAML: YAML

include("Copier.jl")
include("api.jl")
include("guess.jl")

end
