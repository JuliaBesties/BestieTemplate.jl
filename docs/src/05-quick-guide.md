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
    "AddCirrusCI" => true,        # From the hidden optionss
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
