"""
# COPIERTemplate.jl

This package defines a copier template for Julia packages and a basic user interface aroud copier
to use it from Julia.

The main functions are: [`generate`](@ref)
"""
module COPIERTemplate

include("Copier.jl")

"""
    generate(dst_path[, data]; kwargs...)
    generate(src_path, dst_path[, data]; true, kwargs...)

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the COPIERTemplate template.
If `src_path` is not informed, the GitHub URL of COPIERTemplate.jl is used.

The `data` argument is a dictionary of answers (values) to questions (keys) that can be used to bypass some of the interactive questions.

## Keyword arguments

The keyword arguments are passed directly to the internal [`Copier.copy`](@ref).
"""
function generate(src_path, dst_path, data::Dict = Dict(); kwargs...)
  Copier.copy(src_path, dst_path, data; kwargs...)
end

function generate(dst_path, data::Dict = Dict(); kwargs...)
  generate("https://github.com/abelsiqueira/COPIERTemplate.jl", dst_path, data; kwargs...)
end

end
