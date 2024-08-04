"""
Module Debug

Tools for debugging Bestie. Nothing here is public API.

!!! warning
    This file is not tested and not covered in codecov.
    Except for the data, it is not supposed to be used in the tests.

Noteworthy: [`BestieTemplate.Debug.Data`](@ref)
"""
module Debug

using ..BestieTemplate: BestieTemplate, generate, apply

include("Data.jl")
include("helper.jl")

end
