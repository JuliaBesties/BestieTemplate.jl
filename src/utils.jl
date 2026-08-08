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

"""
The `.copier-answers.yml` keys recording which template version and source a project was
last reconciled with. Copier rewrites both on every run, which `add_feature` undoes: it
applies a subset of the template on purpose, so it must not claim the project caught up
with the version it rendered from (#626).
"""
const COPIER_BOOKKEEPING_FIELDS = ("_commit", "_src_path")

"""
    _copier_bookkeeping(path)

The `COPIER_BOOKKEEPING_FIELDS` lines of the answers file at `path`, verbatim and keyed by
field. Kept as text, not parsed values, so restoring cannot reformat them (see
[`_load_copier_answers`](@ref) for how `_commit` can look like a float).
"""
function _copier_bookkeeping(path::AbstractString)
  isfile(path) || return Dict{String, String}()
  return Dict(
    field => line for line in readlines(path) for
    field in COPIER_BOOKKEEPING_FIELDS if startswith(line, "$field:")
  )
end

"""
    _restore_copier_bookkeeping(path, saved)

Put the bookkeeping lines of the answers file at `path` back to `saved`, as returned by
[`_copier_bookkeeping`](@ref) before copier rewrote the file.
"""
function _restore_copier_bookkeeping(path::AbstractString, saved::AbstractDict)
  (isempty(saved) || !isfile(path)) && return nothing
  content = read(path, String)
  for (field, line) in saved
    content = replace(content, Regex("^$field:.*\$", "m") => _ -> line)
  end
  write(path, content)
  return nothing
end
