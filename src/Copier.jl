"""
Wrapper around [copier](https://copier.readthedocs.io/).

There are three functions in this module:

- [`copy`](@ref)
- [`recopy`](@ref)
- [`update`](@ref)
"""
module Copier

using CondaPkg: CondaPkg
using PythonCall: PythonCall

function __init__()
  CondaPkg.add("copier")
end

"""
    copy(dst_path[, data]; kwargs...)
    copy(src_path, dst_path[, data]; kwargs...)

Wrapper around [copier.run_copy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_copy).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
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

Wrapper around [copier.run_recopy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_recopy).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
"""
function recopy(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_recopy(dst_path, data; kwargs...)
end

"""
    update(dst_path[, data]; kwargs...)

Wrapper around [copier.run_update](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_update).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
"""
function update(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_update(dst_path, data; kwargs...)
end

end
