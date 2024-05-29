module COPIERTemplate

using PythonCall, CondaPkg, UUIDs

function __init__()
  CondaPkg.add("copier")
end

"""
    generate(path, generate_missing_uuid = true; kwargs...)

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the COPIERTemplate template.
Even though the template is available offline through this template, this uses the github URL to allow updating.

The keyword arguments are passed directly to the `run_copy` function of `copier`.
If `generate_missing_uuid` is `true` and there is no `kwargs[:data]["PackageUUID"]`, then a UUID is generated for the package.
"""
function generate(path, generate_missing_uuid = true; kwargs...)
  copier = PythonCall.pyimport("copier")
  data = copy(get(kwargs, :data, Dict()))
  if generate_missing_uuid && !("PackageUUID" in keys(data))
    data["PackageUUID"] = string(uuid4())
  end
  copier.run_copy("https://github.com/abelsiqueira/COPIERTemplate.jl", path; kwargs..., data = data, vcs_ref = "HEAD")
end

end
