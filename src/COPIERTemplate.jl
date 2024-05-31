module COPIERTemplate

using PythonCall, CondaPkg, UUIDs

function __init__()
  CondaPkg.add("copier")
end

"""
    generate(dst_path, generate_missing_uuid = true; kwargs...)
    generate(src_path, dst_path, generate_missing_uuid = true; kwargs...)

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the COPIERTemplate template.

If `src_path` is not informed, the GitHub URL of COPIERTemplate.jl is used.

Even though the template is available offline through this template, this uses the github URL to allow updating.

The keyword arguments are passed directly to the `run_copy` function of `copier`.
If `generate_missing_uuid` is `true` and there is no `kwargs[:data]["PackageUUID"]`, then a UUID is generated for the package.
"""
function generate(src_path, dst_path, generate_missing_uuid = true; kwargs...)
  copier = PythonCall.pyimport("copier")
  data = copy(get(kwargs, :data, Dict()))
  if generate_missing_uuid && !("PackageUUID" in keys(data))
    data["PackageUUID"] = string(uuid4())
  end
  copier.run_copy(src_path, dst_path; kwargs..., data = data, vcs_ref = "HEAD")
end

function generate(dst_path, args...; kwargs...)
  generate("https://github.com/abelsiqueira/COPIERTemplate.jl", dst_path, args...; kwargs...)
end

const DEBUGGING = 1

end
