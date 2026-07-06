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
    _copier_tempdir_from_exception(ex)

If `ex` is Copier failing to remove its own temporary VCS clone, return the path of
that temporary clone. Otherwise, return `nothing`.
"""
function _copier_tempdir_from_exception(ex)
  isa(ex, PythonCall.PyException) || return nothing
  PythonCall.pyisinstance(ex.v, PythonCall.pybuiltins.OSError) || return nothing
  filename = PythonCall.pyconvert(Any, ex.v.filename)
  filename isa AbstractString || return nothing
  parts = splitpath(filename)
  i = findfirst(startswith("copier._vcs.clone."), parts)
  isnothing(i) && return nothing
  return joinpath(parts[1:i]...)
end

"""
    _ignore_cleanup_race(f)

Run `f()`, ignoring failures from Copier's cleanup of its temporary VCS clone.

Copier removes its temporary clone only after the requested operation has fully
completed, and on Linux that `shutil.rmtree` intermittently fails with
`OSError: [Errno 39] Directory not empty`. The destination files are already in
place at that point, so the operation is treated as successful and the leftover
temporary clone is removed here instead.
"""
function _ignore_cleanup_race(f)
  try
    f()
  catch ex
    copier_tempdir = _copier_tempdir_from_exception(ex)
    isnothing(copier_tempdir) && rethrow()
    @debug "Ignoring failure to remove Copier's temporary clone" copier_tempdir
    for _ in 1:3
      try
        rm(copier_tempdir; recursive = true, force = true)
        break
      catch
        sleep(0.1)
      end
    end
    nothing
  end
end

"""
    copy(dst_path[, data]; kwargs...)
    copy(src_path, dst_path[, data]; kwargs...)

Wrapper around [copier.run_copy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_copy).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
Note: this is not `Base.copy`, inside the Copier module we shadow that name.
"""
function copy(src_path, dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  _ignore_cleanup_race() do
    copier.run_copy(src_path, dst_path, data; kwargs...)
  end
end

function copy(dst_path, data::Dict = Dict(); kwargs...)
  copy(joinpath(@__DIR__, ".."), dst_path, data; kwargs...)
end

"""
    recopy(dst_path[, data]; kwargs...)

Wrapper around [copier.run_recopy](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_recopy).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
"""
function recopy(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  _ignore_cleanup_race() do
    copier.run_recopy(dst_path; data = data, kwargs...)
  end
end

"""
    update(dst_path[, data]; kwargs...)

Wrapper around [copier.run_update](https://copier.readthedocs.io/en/stable/reference/main/#copier.main.run_update).

This is an internal function, if BestieTemplate's main API is not sufficient, open an issue.
"""
function update(dst_path, data::Dict = Dict(); kwargs...)
  copier = PythonCall.pyimport("copier")
  _ignore_cleanup_race() do
    copier.run_update(dst_path, data; kwargs...)
  end
end

end
