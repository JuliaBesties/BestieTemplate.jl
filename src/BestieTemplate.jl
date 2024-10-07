"""
# BestieTemplate.jl

This package defines a copier template for Julia packages and a basic user interface around copier
to use it from Julia.

The main functions are: [`generate`](@ref), [`apply`](@ref), and [`update`](@ref).

To create a new package using BestieTemplate run

```julia
julia> BestieTemplate.generate("path/to/YourNewPackage.jl")
```

To apply the template to an existing package

```julia
julia> BestieTemplate.apply("path/to/YourExistingPackage.jl")
```

Check the documentation: https://JuliaBesties.github.io/BestieTemplate.jl
"""
module BestieTemplate

using Compat: @compat
using Markdown: @md_str
using TOML: TOML
using YAML: YAML

include("Copier.jl")
include("api.jl")
include("debug/Debug.jl")
include("guess.jl")

end
