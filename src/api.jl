@compat public generate, apply, update

"""
    _copy(src_path, dst_path, data; kwargs...)

Internal function to run common code for new or existing packages.
"""
function _copy(src_path, dst_path, data; kwargs...)
  quiet = get(kwargs, :quiet, false)

  # If the PackageName was not given or guessed from the Project.toml, use the sanitized path
  if !haskey(data, "PackageName")
    package_name = _sanitize_package_name(dst_path)
    if package_name != ""
      quiet || @info "Using sanitized path $package_name as package name"
      data["PackageName"] = package_name
    end
  end

  quiet || display(
    md"""Hi, **❤ Bestie ❤** here.

  Below you will find a few questions to configure your template.
  First, some **required** questions will need to be filled.
  Among them, which strategy for default selection, and whether to be asked for confirmation or not on these defaults.

  We suggest reading the **full guide**, and possibly other documentation pages:

  `https://JuliaBesties.github.io/BestieTemplate.jl/stable/10-full-guide`

  If something does not work as you would expect or you need clarifications,
  please open an issue or discussion.

  **❤ Good luck filling the questions, and thanks for choosing BestieTemplate ❤**
""",
  )
  Copier.copy(src_path, dst_path, data; kwargs...)
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

"""
    generate(dst_path[, data]; kwargs...)
    generate(local_or_online, dst_path[, data]; kwargs...)
    generate(src_path, dst_path[, data]; kwargs...)

Generates a new project at the path `dst_path` using the template.
If the `dst_path` already exists, this will throw an error, unless `dst_path = "."`.
For existing packages, use `BestieTemplate.apply` instead.

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the BestieTemplate template.

`local_or_online` can be either `:local` or `:online`. If it is `:online`, the GitHub URL of BestieTemplate.jl is used. Otherwise, the `pkgdir(BestieTemplate)` is used.

If `src_path` is informed an URL or a path to a compatible template is expected.

The `data` argument is a dictionary of answers (values) to questions (keys) that can be used to bypass some of the interactive questions.
See <https://juliabesties.github.io/BestieTemplate.jl/stable/30-questions/> for a list all questions.

## Keyword arguments

- `warn_existing_pkg::Boolean = true`: Whether to check if you actually meant `update`. If you run `generate` and the `dst_path` contains a `.copier-answers.yml`, it means that the copy was already made, so you might have means `update` instead. When `true`, a warning is shown and execution is stopped.
- `quiet::Boolean = false`: Whether to print greetings, info, and other messages. This keyword is also used by copier.
- `change_permissions::Boolean = false`: Whether to change the permissions of the generated project.

The other keyword arguments are passed directly to the internal [`Copier.copy`](@ref).
"""
function generate(
  src_path::AbstractString,
  dst_path::AbstractString,
  data::Dict = Dict();
  change_permissions = false,
  kwargs...,
)
  quiet = get(kwargs, :quiet, false)

  if dst_path != "." && isdir(dst_path) && length(readdir(dst_path)) > 0
    error("$dst_path already exists. For existing packages, use `BestieTemplate.apply` instead.")
  end

  _copy(src_path, dst_path, data; kwargs...)
  if change_permissions && dst_path != "."
    change_project_permissions(dst_path)
  end

  data = YAML.load_file(joinpath(dst_path, ".copier-answers.yml"))
  package_name = data["PackageName"]
  bestie_version = get(data, "_commit", ":local version")

  has_precommit = isfile(joinpath(dst_path, ".pre-commit-config.yaml"))

  pre_commit_messages = if has_precommit
    (
      first_part = """\$ pre-commit run -a     # Try to fix possible pre-commit issues (failures are possible)
        \$ git add .""",
      second_part = "\$ pre-commit install    # Future commits can't be directly to main unless you use -n",
    )
  else
    (first_part = "", second_part = "")
  end

  if !quiet
    println("""Your package $package_name.jl has been created successfully! 🎉

    Next steps: Create git repository and push to Github.

    julia> exit()  # Exit the Julia REPL
    \$ cd $dst_path
    \$ git init
    \$ git add .""")
    if has_precommit
      println(
        """\$ pre-commit run -a     # Try to fix possible pre-commit issues (failures are possible)
        \$ git add .""",
      )
    end
    println("\$ git commit -m \"Generate repo with BestieTemplate $bestie_version\"")
    if has_precommit
      println(
        "\$ pre-commit install    # Future commits can't be directly to main unless you use -n",
      )
    end
    if !change_permissions && !contains("http")(src_path)
      println(
        "\$ chmod -R u+w $dst_path    # You might have permission issues when copying locally. This should fix it",
      )
    end
    println("""\nCreate a repo on GitHub and push your code to it.

    Read the full guide: https://JuliaBesties.github.io/BestieTemplate.jl/stable/10-full-guide
    """)
  end

  return nothing
end

function generate(dst_path::AbstractString, data::Dict = Dict(); kwargs...)
  # The `:local` mode will
  generate(:local, dst_path, data; change_permissions = true, kwargs...)
end

function generate(local_or_online::Symbol, dst_path::AbstractString, data::Dict; kwargs...)
  @assert local_or_online in (:local, :online)
  change_permissions = false
  src_path = if local_or_online == :local
    change_permissions = true
    pkgdir(BestieTemplate)
  else
    "https://github.com/JuliaBesties/BestieTemplate.jl"
  end

  generate(src_path, dst_path, data; change_permissions, kwargs...)
end

"""
    apply(dst_path[, data]; kwargs...)
    apply(local_or_online, dst_path[, data]; kwargs...)
    apply(src_path, dst_path[, data]; kwargs...)

Applies the template to an existing project at path ``dst_path``.
If the `dst_path` does not exist, this will throw an error.
For new packages, use `BestieTemplate.generate` instead.

Runs the `copy` command of [copier](https://github.com/copier-org/copier) with the BestieTemplate template, with `overwrite = true`.
If `src_path` is not informed, the GitHub URL of BestieTemplate.jl is used.

The `data` argument is a dictionary of answers (values) to questions (keys) that can be used to bypass some of the interactive questions.

## Keyword arguments

- `guess:Bool = true`: Whether to try to guess some of the data from the package itself.
- `warn_existing_pkg::Bool = true`: Whether to check if you actually meant `update`. If you run `apply` and the `dst_path` contains a `.copier-answers.yml`, it means that the copy was already made, so you might have means `update` instead. When `true`, a warning is shown and execution is stopped.
- `quiet::Bool = false`: Whether to print greetings, info, and other messages. This keyword is also used by copier.
- `change_permissions::Boolean = false`: Whether to change the permissions of the destination project.

The other keyword arguments are passed directly to the internal [`Copier.copy`](@ref).
"""
function apply(
  src_path::AbstractString,
  dst_path::AbstractString,
  data::Dict = Dict();
  warn_existing_pkg = true,
  guess = true,
  change_permissions = false,
  kwargs...,
)
  quiet = get(kwargs, :quiet, false)

  if !isdir(dst_path)
    error("$dst_path does not exist. For new packages, use `BestieTemplate.generate` instead.")
  end
  if !isdir(joinpath(dst_path, ".git"))
    error("""No folder $dst_path/.git found. Are you using git on the project?
          To apply to existing packages, git is required to avoid data loss.""")
  end

  if warn_existing_pkg && isfile(joinpath(dst_path, ".copier-answers.yml"))
    @warn """There already exists a `.copier-answers.yml` file in the destination path.
    You might have meant to use `BestieTemplate.update` instead, which only fetches the non-applying updates.
    If you really meant to use this command, then pass the `warn_existing_pkg = false` flag to this call.
    """

    return nothing
  end

  # If there are answers in the destination path, skip guessing the answers
  existing_data = guess ? _read_data_from_existing_path(dst_path) : Dict()
  for (key, value) in existing_data
    quiet || @info "Inferred $key=$value from destination path"
    if haskey(data, key)
      quiet || @info "  Being overriden by supplied $key=$(data[key]) value"
    end
  end
  data = merge(existing_data, data)

  _copy(src_path, dst_path, data; overwrite = true, kwargs...)
  if change_permissions && dst_path != "."
    change_project_permissions(dst_path)
  end

  data = YAML.load_file(joinpath(dst_path, ".copier-answers.yml"))
  package_name = data["PackageName"]
  bestie_version = get(data, "_commit", ":local version")

  quiet || println("""BestieTemplate was applied to $package_name.jl! 🎉

      Next steps:

      Review the modifications.
      In particular README.md and docs/src/index.md tend to be heavily edited.

      \$ exit() # Exit the Julia REPL
      \$ git switch -c apply-bestie # If you haven't created a branch
      \$ git add .
      \$ pre-commit run -a # Try to fix possible pre-commit issues (failures are expected)
      \$ pre-commit run -a # Again. Now failures should not happen
      \$ git add .
      \$ git commit -m "Apply BestieTemplate $bestie_version"
      \$ pre-commit install
      \$ git push -u origin apply-bestie

      Go to GitHub and create a Pull Request from apply-bestie to main.
      Continue on the full guide: https://JuliaBesties.github.io/BestieTemplate.jl/stable/10-full-guide
      """)

  return nothing
end

function apply(dst_path::AbstractString, data::Dict = Dict(); kwargs...)
  apply(:local, dst_path, data; change_permissions = true, kwargs...)
end

function apply(local_or_online::Symbol, dst_path::AbstractString, data::Dict = Dict(); kwargs...)
  @assert local_or_online in (:local, :online)
  change_permissions = false
  src_path = if local_or_online == :local
    change_permissions = true
    pkgdir(BestieTemplate)
  else
    "https://github.com/JuliaBesties/BestieTemplate.jl"
  end

  apply(src_path, dst_path, data; change_permissions = change_permissions, kwargs...)
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
