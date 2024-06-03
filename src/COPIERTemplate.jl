module COPIERTemplate

using PythonCall, CondaPkg, UUIDs

function __init__()
  CondaPkg.add("copier")
end

"""
    generate(dst_path; kwargs...)
    generate(src_path, dst_path; kwargs...)

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the COPIERTemplate template.

If `src_path` is not informed, the GitHub URL of COPIERTemplate.jl is used.

Even though the template is available offline through this template, this uses the github URL to allow updating.

The keyword arguments are passed directly to the `run_copy` function of `copier`.
"""
function generate(src_path, dst_path; kwargs...)
  copier = PythonCall.pyimport("copier")
  copier.run_copy(src_path, dst_path; kwargs..., vcs_ref = "HEAD")
end

function generate(dst_path, args...; kwargs...)
  generate("https://github.com/abelsiqueira/COPIERTemplate.jl", dst_path, args...; kwargs...)
end

end
