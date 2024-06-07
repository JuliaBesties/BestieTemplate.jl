"""
# COPIERTemplate.jl

This package defines a copier template for Julia packages and a basic user interface aroud copier
to use it from Julia.

The main functions are: [`generate`](@ref)
"""
module COPIERTemplate

include("Copier.jl")

using TOML: TOML

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
  # If there are answers in the destionation path, skip guessing the answers
  if !isfile(joinpath(dst_path, ".copier-answers")) && isdir(dst_path)
    existing_data = _read_data_from_existing_path(dst_path)
    for (key, value) in existing_data
      @info "Inferred $key=$value from destination path"
      if haskey(data, key)
        @info "  Being overriden by supplied $key=$(data[key]) value"
      end
    end
    data = merge(existing_data, data)
  end
  # If the PackageName was not given or guessed from the Project.toml, use the sanitized path
  if !haskey(data, "PackageName")
    package_name = _sanitize_package_name(dst_path)
    if package_name != ""
      @info "Using sanitized path $package_name as package name"
      data["PackageName"] = package_name
    end
  end
  Copier.copy(src_path, dst_path, data; kwargs...)
end

function generate(dst_path, data::Dict = Dict(); kwargs...)
  generate("https://github.com/abelsiqueira/COPIERTemplate.jl", dst_path, data; kwargs...)
end

"""
    update([data]; kwargs...)
    update(dst_path[, data]; kwargs...)

Run the update command of copier, updating the `dst_path` (or the current path if omitted) with a new version of the template with a new version of the template.

The `data` argument is a dictionary of answers (values) to questions (keys) that can be used to bypass some of the interactive questions.

## Keyword arguments

The keyword arguments are passed directly to the internal [`Copier.update`](@ref).
"""
function update(dst_path, data::Dict = Dict(); kwargs...)
  Copier.update(dst_path, data; overwrite = true, kwargs...)
end

function update(data::Dict = Dict(); kwargs...)
  update(".", data; overwrite = true, kwargs...)
end

"""
    data = _read_data_from_existing_path(dst_path)

Reads the destination folder to figure out some answers.
"""
function _read_data_from_existing_path(dst_path)
  data = Dict{String, Any}()
  if isfile(joinpath(dst_path, "Project.toml"))
    toml_data = TOML.parsefile(joinpath(dst_path, "Project.toml"))
    for (toml_key, copier_key) in [("name", "PackageName"), ("uuid", "PackageUUID")]
      if haskey(toml_data, toml_key)
        data[copier_key] = toml_data[toml_key]
      end
    end
    # Author capture is limited and does not handle multiple authors. See #118 for more information.
    if haskey(toml_data, "authors")
      author_regex = r"^(.*) <(.*)>(?: and contributors)?"
      m = match(author_regex, toml_data["authors"][1])
      if !isnothing(m)
        data["AuthorName"] = m[1]
        data["AuthorEmail"] = m[2]
      end
    end
  end

  return data
end

"""
    package_name = _sanitize_package_name(path)

Sanitize the `path` to guess the package_name by looking at the
base name and removing an extension. If the result is not a valid
identifier, returns "".
"""
function _sanitize_package_name(dst_path)
  package_name = dst_path |> basename |> splitext |> first
  return Base.isidentifier(package_name) ? package_name : ""
end

end
