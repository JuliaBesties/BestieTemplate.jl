
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
