"""
# COPIERTemplate.jl

This package defines a copier template for Julia packages and a basic user interface aroud copier
to use it from Julia.

The main functions are: [`generate`](@ref)
"""
module COPIERTemplate

using PythonCall, CondaPkg, UUIDs

function __init__()
  CondaPkg.add("copier")
end

"""
    copy(dst_path[, data]; kwargs...)
    copy(src_path, dst_path[, data]; kwargs...)

Wrapper around Python's [copier.run_copy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_copy).
Use [`generate`](@ref) for a more user-friendly function.
"""
function Base.copy(src_path, dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_copy(src_path, dst_path, data; kwargs...)
end

function Base.copy(dst_path, data::Dict = Dict(); kwargs...)
  copy(joinpath(@__DIR__, ".."), dst_path, data; kwargs...)
end

"""
    recopy(dst_path[, data]; kwargs...)

Wrapper around Python's [copier.run_recopy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_recopy).
"""
function recopy(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_recopy(dst_path, data; kwargs...)
end

"""
    update(dst_path[, data]; kwargs...)

Wrapper around Python's [copier.run_update](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_update).
"""
function update(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_update(dst_path, data; kwargs...)
end

"""
    generate(dst_path[, data]; kwargs...)
    generate(src_path, dst_path[, data]; true, kwargs...)

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the COPIERTemplate template.
If `src_path` is not informed, the GitHub URL of COPIERTemplate.jl is used.

The `data` argument is a dictionary of answers (values) to questions (keys) that can be used to bypass some of the interactive questions.

## Keyword arguments

The keyword arguments are passed directly to [`copy`](@ref).
"""
function generate(src_path, dst_path, data::Dict = Dict(); kwargs...)
  copy(src_path, dst_path, data; kwargs...)
end

function generate(dst_path, data::Dict = Dict(); kwargs...)
  generate("https://github.com/abelsiqueira/COPIERTemplate.jl", dst_path, data; kwargs...)
end

end
