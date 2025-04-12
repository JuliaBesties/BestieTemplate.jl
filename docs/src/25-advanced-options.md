# [Advanced options and non-interactive answers](@id advanced_options)

The answers to any question can be explicitly passed to the API functions to skip the question.
Three secrets are unveiled.

## Advanced (or hidden) options

Some options are not part of any of the strategies, i.e., they are only available in two ways:

1. Use [`BestieTemplate.generate`](@ref) (or [`BestieTemplate.apply`](@ref), if updating), and after selecting the strategy, answer "Y" to the question "Do you want review each excludedj item?"
2. Explicitly pass the answer via a `Dict(...)` to the `data` (or `extra_data`) argument of any of the API functions. More details below.

### Passing the answer explicitly

The functions [`BestieTemplate.generate`](@ref), [`BestieTemplate.apply`](@ref), and [`BestieTemplate.new_pkg_quick`](@ref) accept a dictionary as optional positional argument (see their docs).
This dictionary lists the keys of the questions and the answers to the questions.
So, for instance, if you want to have a "Tiny" package, except that you want `pre-commit`, you can create one by making a small change to the [example of changing details of `new_pkg_quick`](@ref quick_new_pkg_with_data):

```@setup advanced_options_examples
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

```@example advanced_options_examples
using BestieTemplate: new_pkg_quick

root_dir = mktempdir() # hide
pkg_destination = joinpath(root_dir, "TinyWithPrecommit.jl")
package_owner = "JuliaBesties"
authors = "JuliaBesties maintainers"

extra_data = Dict("AddPrecommit" => true)
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
