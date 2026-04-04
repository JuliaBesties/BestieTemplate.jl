@compat public new_pkg_quick, only_testitem_cli, only

const JULIA_LTS_VERSION = "1.10"

"""
    new_pkg_quick(
        pkg_destination,
        package_owner,
        authors,
        strategy::Symbol,
        extra_data = Dict();
        license = "MIT",
        local_template_path = pkgdir(BestieTemplate),
        template_source = :online,
        use_latest = false,
        kwargs...;
    )

Creates a new package using defaults and no interaction.

Convenience function that requires the least amount of information to
generate a package using the "Tiny" strategy.

## Arguments

- `pkg_destination`: Path to the folder where the package will be created.
   Examples: `"NewPkg.jl"`, `"."`, `"~/.julia/dev/NewPkg.jl"`
- `package_owner`: GitHub username or organization that owns the package (This
   will be used for URLs). Examples: `"JuliaBesties"`, `"username"`
- `authors`: Package authors separated by commas (We recommend the form "NAME
   <EMAIL>", but this can be ignored). Examples: `"JuliaBesties maintainers"`,
   `"Alice <alice@alice.com>, Bob <bob@bob.nl>"`
- `strategy::Symbol`: Which strategy to use. Values: `:tiny`, `:light`, `:moderate`, and `:robust`
- `extra_data`: Dictionary with extra data to be added to the answers file.
   Default: `Dict()`. Examples: `Dict("AddDocs" => true)`. See the
   [Questions](@ref) section for all the options.

## Keyword arguments

- `license`: Which license to add. Default: `MIT`. Choices: `"Apache-2.0"`, `"GPL-3.0"`, `"MIT"`, `"MPL-2.0"`, `"nothing"`.
- `local_template_path`: Template path to use when `template_source = :local`. Default: `pkgdir(BestieTemplate)`
- `template_source::Symbol`: Source of the template, either `:local` or `:online`. `:local` uses the path of the BestieTemplate package as given by the keyword `local_template_path`, and `:online` uses the GitHub URL. Notice that using `:local` will freeze the version to a folder, so manual update is necessary. Default: `:online`.
- `use_latest::Bool`: Whether to use the latest commit of the template
  (otherwise use the last release). Default: `false`.
- Additional keyword arguments are passed directly to `generate`.
"""
function new_pkg_quick(
  pkg_destination,
  package_owner,
  authors,
  strategy::Symbol,
  extra_data = Dict();
  license = "MIT",
  local_template_path = pkgdir(BestieTemplate),
  template_source::Symbol = :online,
  use_latest::Bool = false,
  kwargs...,
)
  # Ensure valid strategy
  strategy_lookup = Dict(:tiny => 0, :light => 1, :moderate => 2, :robust => 3)
  if !haskey(strategy_lookup, strategy)
    error("Unknown strategy: $strategy")
  end

  change_permissions = false
  # Ensure valid template source
  template_path = if template_source == :local
    change_permissions = true
    if !isdir(joinpath(local_template_path, ".git"))
      @warn "Local path $local_template_path is not tracked with .git, updates won't be possible without manual intervention"
    end
    local_template_path
  elseif template_source == :online
    "https://github.com/JuliaBesties/BestieTemplate.jl"
  else
    error("Unknown template source: $template_source")
  end

  # Merge data, ensuring explicit arguments override implicit ones
  data = merge(
    Dict(
      "PackageOwner" => package_owner,
      "PackageUUID" => string(UUIDs.uuid4(MersenneTwister(123))),
      "Authors" => authors,
      "License" => license,
      "StrategyLevel" => strategy_lookup[strategy],
      "StrategeConfirmIncluded" => false,
      "StrategyReviewExcluded" => false,
    ),
    extra_data,
  )

  extra_args = Dict{Symbol, Any}()
  if use_latest
    extra_args[:vcs_ref] = "HEAD"
  end

  generate(
    template_path,
    pkg_destination,
    data;
    defaults = true,
    quiet = true,
    change_permissions = change_permissions,
    kwargs...,
    extra_args...,
  )
end

"""
    only_testitem_cli(dst_path[, data]; kwargs...)

Convenience alias for `only(:testitem_cli, dst_path, data; kwargs...)`.
See [`only`](@ref) for details.
"""
only_testitem_cli(args...; kwargs...) = only(:testitem_cli, args...; kwargs...)

# Feature specs for `only`: return (forced_data, included_files, required_fields)
_only_spec(::Val{:testitem_cli}) =
  (Dict("TestingStrategy" => "testitem_cli"), ["test/runtests.jl"], String[])

"""
    only(feature::Symbol, dst_path[, data]; kwargs...)

Selectively regenerate specific template files for an existing package.

Reads `.copier-answers.yml` (if present) and guesses data from the package,
then applies only the files relevant to `feature`. If `.copier-answers.yml`
exists, it is updated; otherwise no answers file is created.

## Supported features

- `:testitem_cli` — regenerates `test/runtests.jl` with the `testitem_cli` testing strategy

## Arguments

- `feature::Symbol`: Which feature to apply.
- `dst_path`: Path to the existing package.
- `data`: Optional dictionary of additional data to merge. Default: `Dict()`.

## Keyword arguments

- `local_template_path`: Template path. Default: `pkgdir(BestieTemplate)`.
- Additional keyword arguments are passed to `Copier.copy` (e.g. `vcs_ref`).

## Merge priority

`feature-specific forced data > data > guessed > copier_answers`
"""
function only(
  feature::Symbol,
  dst_path::AbstractString,
  data::Dict = Dict();
  local_template_path = pkgdir(BestieTemplate),
  kwargs...,
)
  forced_data, included_files, required_fields = _only_spec(Val(feature))

  answers_path = joinpath(dst_path, ".copier-answers.yml")
  has_answers = isfile(answers_path)

  base_data = if has_answers
    d = YAML.load_file(answers_path)
    Dict(k => v for (k, v) in d if !startswith(k, "_"))
  else
    Dict()
  end

  guessed_data = _read_data_from_existing_path(dst_path)
  merged_data = merge(base_data, guessed_data, data, forced_data)

  # Check feature-specific required fields
  missing_fields = filter(k -> !haskey(merged_data, k), required_fields)
  if !isempty(missing_fields)
    error("""Cannot determine required fields: $(join(missing_fields, ", ")).
          Pass them via the `data` argument or run `BestieTemplate.apply` first.""")
  end

  # Provide placeholders for copier questions that the feature's files don't reference
  copier_required = ["PackageName", "PackageOwner", "Authors"]
  for field in copier_required
    if !haskey(merged_data, field)
      merged_data[field] = "UNUSED"
    end
  end

  # Only update .copier-answers.yml when it already exists;
  # don't create it for packages not managed by BestieTemplate.
  excluded = ["**"]
  for f in included_files
    push!(excluded, "!$f")
  end
  if has_answers
    push!(excluded, "!.copier-answers.yml")
  end

  copier_defaults =
    Dict{Symbol, Any}(:defaults => true, :overwrite => true, :quiet => true, :vcs_ref => "HEAD")
  Copier.copy(
    local_template_path,
    abspath(dst_path),
    merged_data;
    merge(copier_defaults, Dict{Symbol, Any}(kwargs))...,
    # pylist required: PythonCall auto-converts simple types (Bool, String)
    # but NOT Julia Vector{String} when passed as kwargs to Python functions.
    exclude = pylist(excluded),
  )
end
