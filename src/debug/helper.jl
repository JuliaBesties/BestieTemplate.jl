function rand_pkg_name()
  prob_done = 0.0
  pkg_name = "PkgDebugBestie"
  n = 1
  while isdir("$(pkg_name)$n")
    n += 1
  end
  return "$(pkg_name)$n"
end

"""
    dbg_data(data_choice, more_data)

Returns the fake debug data merged with `more_data`.
The options for `data_choice` are:

- `:nothing`, `:none`: No random data.
- `:required`, `:req`: Only the required data is generated. You get asked which choice of optional data.
- `:minimum`, `:min`: The required data plus the choice "minimum" for optional data.
- `:recommended`, `:rec`: The required data plus the choice "recommended" for optional data.
- `:ask`: The required data plus the choice "ask". The optional questions will be asked.
- `:ask_default`: Same as `:ask` plus the default answers for the optional questions.
- `:ask_and_say_no`: Same as `:ask` plus answers no/false to the optional questions.
- `:ask_and_say_yes`: Same as `:ask` plus answers yes/true to the optional questions.
"""
function dbg_data(data_choice, _data = Dict())
  data = if data_choice in [:nothing, :none]
    Dict()
  elseif data_choice in [:required, :req]
    Data.minimum_defaults
  elseif data_choice in [:minimum, :min]
    Data.strategy_minimum
  elseif data_choice in [:recommended, :recommended_only, :rec, :rec_only]
    Data.strategy_recommended_only
  elseif data_choice in [:recommended_ask, :rec_ask]
    Data.strategy_recommended_ask
  elseif data_choice in [:ask]
    Data.strategy_ask
  elseif data_choice in [:ask_default]
    Data.strategy_ask_default
  elseif data_choice in [:ask_and_say_no]
    Data.strategy_ask_and_say_no
  elseif data_choice in [:ask_and_say_yes]
    Data.strategy_ask_and_say_yes
  else
    error("Unexpected $data_choice")
  end
  data = merge(data, _data)
end

"""
    dbg_generate([dst_path, data]; data_choice=:minimum)

Convenience function to help debug `generate`.

It runs `generate` with the `dst_path` destination (random by default) and the given `data`
(nothing by default).

It also uses a `data_choice` to determine fake starting data. This is passed to
[`dbg_data`](@ref).

This function can be called in multiple ways:

- `dbg_generate()`: Use all defaults
- `dbg_generate(my_data::Dict)`: Use `my_data` and all defaults
- `dbg_generate(dst_path::String)`: Use `dst_path` and all defaults
- `dbg_generate(data_choice::Symbol)`: Use all defaults and `data_choice` to generate `my_data`

It uses the `pkgdir` location of Bestie and adds the flags

- `defaults = true`: Sent to copier to use the default answers.
- `quiet = true`: Low verbosity.
- `vcs_ref = HEAD`: Use the development version of the template, including dirty repo
  changes.
"""
function dbg_generate(
  dst_path::String = rand_pkg_name(),
  _data::Dict = Dict();
  data_choice::Symbol = :minimum,
  kwargs...,
)
  data = dbg_data(data_choice, _data)
  BestieTemplate.generate(
    pkgdir(BestieTemplate),
    dst_path,
    data;
    defaults = true,
    quiet = true,
    vcs_ref = "HEAD",
    kwargs...,
  )
end

dbg_generate(_data::Dict, kwargs...) = dbg_generate(rand_pkg_name(), _data; kwargs...)
dbg_generate(data_choice::Symbol, kwargs...) =
  dbg_generate(rand_pkg_name(), Dict(); data_choice, kwargs...)

"""
    dbg_apply([dst_path, data]; data_choice=:minimum)

Convenience function to help debug `apply`.
It runs `apply` with the `dst_path` destination and the given `data`
(nothing by default).

It also uses a `data_choice` to determine fake starting data. This is passed to
[`dbg_data`](@ref).

It uses the `pkgdir` location of Bestie and adds the flags

- `defaults = true`: Sent to copier to use the default answers.
- `quiet = true`: Low verbosity.
- `overwrite = true`: Overwrite all files.
- `vcs_ref = HEAD`: Use the development version of the template, including dirty repo
  changes.
"""
function dbg_apply(dst_path, _data = Dict(); data_choice::Symbol = :minimum, kwargs...)
  data = dbg_data(data_choice, _data)
  BestieTemplate.apply(
    pkgdir(BestieTemplate),
    dst_path,
    data;
    defaults = true,
    overwrite = true,
    quiet = true,
    vcs_ref = "HEAD",
    kwargs...,
  )
end
