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
