# [Quick start guide/How-to's](@id quick_guide)

```@setup quick_start_guide
function tree_of_folder(folder, visited::Vector{String} = [])
  visited = copy(visited)
  base_indent = length(split(pkg_destination, "/"))

  key_transform(root, file) = replace(joinpath(root, file), r"[A-z]*\.jl" => "...")

  if length(visited) > 0
    println("Everything from the level above plus:\n")
  end

  for (root, dirs, files) in walkdir(pkg_destination)
    if any(splitpath(root) .== ".git")
      continue
    end
    ignore_this_whole_root = true
    for (sub_root, sub_dirs, sub_files) in walkdir(root)
      for sub_file in sub_files
        if !(key_transform(sub_root, sub_file) in visited)
          ignore_this_whole_root = false
          break
        end
      end
    end
    if ignore_this_whole_root
      continue
    end

    indent = length(split(root, "/"))

    println("  "^(indent - base_indent) * "- " * split(root, "/")[end] * "/")
    for file in files
      if key_transform(root, file) in visited
        continue
      end
      push!(visited, key_transform(root, file))
      println("  "^(indent - base_indent + 1) * "- " * file)
    end
  end

  return visited
end
```

To create a new package using the template, use either [`BestieTemplate.generate`](@ref) or [`BestieTemplate.new_pkg_quick`](@ref).

To apply a template to an existing package, use either [`BestieTemplate.apply`](@ref).

In this page we have gathered short examples, focused on some use cases.

For a more in-depth guide, check the [Full guide](@ref full_guide)

## Interactive/Wizard experience

```@example wizard
using BestieTemplate: generate

root_dir = mktempdir()

min_data = Dict( # hide
    "PackageOwner" => "JuliaBesties", # hide
    "Authors" => "JuliaBesties maintainers", # hide
) # hide

pkg_destination = joinpath(root_dir, "NewPkg.jl")
generate(
    :local, # hide
    # :local or :online,
    pkg_destination, # full path to the package
    # Dict("Question" => Answer), # to manually set answers
    # defautls = true,
    # quiet = true,
    # use_latest = true,
    min_data, # hide
    defaults = true, # hide
    quiet = true, # hide
    vcs_ref = "HEAD", # hide
)
# Answer a bunch of questions
```

## Quick Tiny package

A minimalist package.

```@example quick_start_guide
using BestieTemplate: new_pkg_quick

root_dir = mktempdir()

pkg_destination = joinpath(root_dir, "TinyPackage.jl")
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :tiny,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder:
visited = tree_of_folder(pkg_destination, String[]) # hide
nothing # hide
```

## Quick Light package

The common niceties: documentation, CI, `.JuliaFormatter.toml` and other config
files that you might want to use (but won't affect you if you don't).

```@example quick_start_guide
using BestieTemplate

pkg_destination = joinpath(root_dir, "LightPackage.jl")
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :light,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder:
visited = tree_of_folder(pkg_destination, visited) # hide
nothing # hide
```

## Quick Moderate package

Opinionated suggestions for more stable packages without sacrificing too much development speed.

```@example quick_start_guide
using BestieTemplate

pkg_destination = joinpath(root_dir, "ModeratePackage.jl")
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :moderate,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder:
visited = tree_of_folder(pkg_destination, visited) # hide
nothing # hide
```

## Quick Robust package

Opinionated selection to help with larger packages and more developers.

```@example quick_start_guide
using BestieTemplate

pkg_destination = joinpath(root_dir, "RobustPackage.jl")
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :robust,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder:
visited = tree_of_folder(pkg_destination, visited) # hide
nothing # hide
```

## Apply to an existing package

Here is an example of applying the template to an existing package.

This is the existing package:

```@example quick_start_guide
pkg_destination = joinpath(root_dir, "ExistingPackage.jl")
package_owner = "JuliaBesties" # hide
authors = "JuliaBesties maintainers" # hide
# Let's pretend is not a template package deleting the .copier-answers.yml file from a tiny new pkg # hide
new_pkg_quick(pkg_destination, package_owner, authors, :tiny, template_source = :local, use_latest = true) # hide
rm(joinpath(pkg_destination, ".copier-answers.yml"), force=true) # hide
# Git is necessary to apply the template to a package # hide
cd(pkg_destination) do # hide
    run(`git init -q`) # hide
    run(`git add .`) # hide
    run(`git config user.name "JuliaBesties"`) # hide
    run(`git config user.email "julia@juliabesties.com"`) # hide
    run(`git commit -q -m "First Commit"`) # hide
end # hide
visited = tree_of_folder(pkg_destination, String[]) # hide
nothing # hide

data = Dict("AddPrecommit" => true, "PackageOwner" => package_owner, "Authors" => authors) # hide
```

Now we apply the template.

```@example quick_start_guide
using BestieTemplate: apply
apply(
    :local, # hide
    # :local or :online,
    pkg_destination, # full path to the package
    data, # hide
    # Dict("Question" => Answer), # to manually set answers
    # defautls = true,
    # quiet = true,
    # use_latest = true,
    defaults = true, # hide
    quiet = true, # hide
    vcs_ref = "HEAD", # hide
)

# You will be asked questions. For instance, if we only select to add pre-commit, this would be the result:
visited = tree_of_folder(pkg_destination, String[]) # hide
nothing # hide
```

## [Change details with `new_pkg_quick`](@id quick_new_pkg_with_data)

For more details on the hidden options see the [Advanced options and non-interactive answers](@ref advanced_options section.

```@example quick_start_guide
using BestieTemplate: new_pkg_quick

pkg_destination = joinpath(root_dir, "TinyPackage.jl")
rm(pkg_destination, recursive=true, force=true) # hide
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"

# Explicitly setting options
extra_data = Dict(
    "JuliaMinVersion" => "1.0",   # From the essential questions that `:tiny` autocompletes
    "AddDocs" => true,            # From the :light strategy
    "AddLintCI" => true,          # From the :moderate strategy
    "AddAllcontributors" => true, # From the :robust strategy
    "AddPrecommitUpdateCI" => true, # From the hidden options
)
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :tiny,
    extra_data,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder: (Notice the new files in comparison to :tiny
visited = tree_of_folder(pkg_destination, String[]) # hide
nothing # hide
```

## Adding features directly via bestie CLI

If you only want one or two files from the template — a `CHANGELOG.md`, a `dependabot.yml`, a pre-commit config — without installing Julia or going through the full `apply`/`update` flow, use the experimental [`bestie-template`](https://pypi.org/p/bestie-template) Python package. It only needs [uv](https://docs.astral.sh/uv/) on the `PATH`, no install step required:

```sh
uvx --from bestie-template bestie list-features
uvx --from bestie-template bestie add-feature changelog,dependabot path/to/MyPackage.jl
```

(`--from bestie-template` is needed because the PyPI package is named `bestie-template`, while the command it installs is `bestie`.)

`list-features` prints every feature `bestie` can add, along with the answers each one needs and the files it writes; pass `--json` for a machine-readable version. `add-feature` then applies one or more features (comma-separated, no spaces) to the package at the given path — each feature writes only the files it owns, leaving the rest of the package untouched.

A few things worth knowing before running it:

- **It overwrites without asking.** A feature replaces its own files outright — no diff, no conflict prompt, no backup. Commit or stash first, so `git diff`/`git checkout` remains your way to undo it.
- **Some features need existing answers.** A few features (e.g. `lint_action`) read `.copier-answers.yml` to decide what to render, and refuse to run without it. Check `list-features --json` for an `_explicit` variant first — it takes the same information as `-d KEY=VALUE` flags instead.
- **Version pinning.** `--ref vX.Y.Z` pins the template version used to render the feature; omit it to use the latest release, or pass `--ref main` for a feature that has not shipped in a release yet.

For AI coding agents, this same workflow is packaged as the [`bestie-features` skill](https://github.com/JuliaBesties/BestieTemplate.jl/blob/main/skills/bestie-features/SKILL.md), which teaches an agent the feature names, how to resolve the answers each one needs, and the follow-up work some features require. Install it with [`npx skills add JuliaBesties/BestieTemplate.jl`](https://www.skills.sh).

## Adding a single feature with `add_feature`

The same idea is available from Julia, through [`BestieTemplate.add_feature`](@ref): apply one named slice of the template — say, just the changelog — to an existing package, without going through the full `apply`/`update` flow.

Here, `AnswerPackage.jl` already has a `.copier-answers.yml` (from `new_pkg_quick`/`generate`/`apply`), so `add_feature` reads the answers it needs — `PackageOwner`, `PackageName` — straight from it:

```@example quick_start_guide
using BestieTemplate: add_feature

pkg_destination = joinpath(root_dir, "AnswerPackage.jl")
package_owner = "JuliaBesties" # hide
authors = "JuliaBesties maintainers" # hide
new_pkg_quick(pkg_destination, package_owner, authors, :tiny, template_source = :local, use_latest = true) # hide

add_feature(
    :changelog,
    pkg_destination,
    template_source = :local, # hide
    use_latest = true, # hide
)

# Resulting folder: (Notice the new CHANGELOG.md)
visited = tree_of_folder(pkg_destination, String[]) # hide
nothing # hide
```

On a package with no `.copier-answers.yml`, `add_feature` still guesses what it can from the package itself — `PackageName`, `Authors` and `JuliaMinVersion` from `Project.toml`, `PackageOwner` from `docs/make.jl` if present, indentation from `.JuliaFormatter.toml` — and only complains about what's left. For a `:tiny` package, which has no `docs/make.jl`, that's `PackageOwner`:

```julia-repl
julia> add_feature(:changelog, pkg_destination)
ERROR: Cannot determine required fields: PackageOwner.
      Pass them via the `data` argument or run `BestieTemplate.apply` first.
```

Pass whatever it names through the `data` argument: `add_feature(:changelog, pkg_destination, Dict("PackageOwner" => "JuliaBesties"))`.

As with `add-feature` from the CLI, this overwrites the feature's files outright, and a git repository is your only way to undo it. See the [`BestieTemplate.add_feature`](@ref) docstring for the full list of features and their required answers, and the [Full guide](@ref full_guide) for how the recorded template version is affected.
