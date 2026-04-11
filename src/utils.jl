"""
    change_project_permissions(project_path)

Change the permission of all files in the `project_path` to 644 and folders to 755.
"""
function change_project_permissions(project_path)
  @assert project_path != "."
  for (root, dirs, files) in walkdir(project_path)
    for dir in dirs
      chmod(joinpath(root, dir), 0o755)
    end
    for file in files
      chmod(joinpath(root, file), 0o644)
    end
  end

  return nothing
end

"""
    _load_copier_answers(path)

Read a `.copier-answers.yml` file and return the parsed `Dict`.

Overrides YAML's float tag to keep `_commit` values that would otherwise be
parsed as a float (e.g. `64e3774 = 64.0 * 10^3774`, a git short SHA copier
wrote unquoted) as strings.
"""
function _load_copier_answers(path::AbstractString)
  float_as_string = Dict{String, Function}(
    "tag:yaml.org,2002:float" => (c, n) -> string(YAML.construct_scalar(c, n)),
  )
  return YAML.load_file(path, float_as_string)
end
