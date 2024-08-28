
"""
    data = _read_data_from_existing_path(dst_path)

Reads the destination folder to figure out some answers.
"""
function _read_data_from_existing_path(dst_path)
  data = Dict{String, Any}()
  _j(files...) = joinpath(dst_path, files...)

  # Project.toml
  if isfile(_j("Project.toml"))
    toml_data = TOML.parsefile(_j("Project.toml"))
    for (toml_key, copier_key) in [("name", "PackageName"), ("uuid", "PackageUUID")]
      if haskey(toml_data, toml_key)
        data[copier_key] = toml_data[toml_key]
      else
        @debug "No key $toml_key in TOML"
      end
    end

    # Author capture is limited and does not handle multiple authors. See #118 for more information.
    if haskey(toml_data, "authors")
      author_regex = r"^(.*) <(.*)>(?: and contributors)?"
      m = match(author_regex, toml_data["authors"][1])
      if !isnothing(m)
        data["AuthorName"] = m[1]
        data["AuthorEmail"] = m[2]
      else
        @debug "authors field don't match regex"
      end
    else
      @debug "No authors information"
    end

    # Minimum Julia version
    if haskey(toml_data, "compat") && haskey(toml_data["compat"], "julia")
      data["JuliaMinVersion"] = toml_data["compat"]["julia"]
    else
      @debug "No compat information"
    end
  else
    @debug "No Project.toml"
  end

  # Get the package owner **without** assuming the github.user (e.g., forks would be wrong)
  if isfile(_j("docs", "make.jl"))
    pkg_name = get(data, "PackageName", r"[[:alnum:]-]*")
    owner_repo_regex = r"([[:alnum:]-]*)\/" * pkg_name * ".jl" # to avoid using ugly Regex(...) syntax

    # docs/make.jl can have the repo keyword in two places (see template)
    # this should match optional
    repo_regex = r"repo\s*=\s*\"(?:https?:\/\/)?.*\/" * owner_repo_regex
    m = match(repo_regex, read(_j("docs", "make.jl"), String))

    if !isnothing(m)
      data["PackageOwner"] = m[1]
    else
      @debug "No match for repo regex"
    end
  else
    @debug "No file docs/make.jl"
  end

  # Check JuliaFormatter for default indentation
  if isfile(_j(".JuliaFormatter.toml"))
    toml_data = TOML.parsefile(_j(".JuliaFormatter.toml"))
    if haskey(toml_data, "indent")
      data["Indentation"] = toml_data["indent"]
    else
      @debug "No indent found in .JuliaFormatter.toml"
    end
  else
    @debug "No file .JuliaFormatter.toml"
  end

  return data
end
