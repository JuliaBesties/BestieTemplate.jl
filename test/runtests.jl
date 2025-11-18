#!/usr/bin/env julia

using Pkg
using TestItemRunner
using TOML

function _print_help()
  @info """Command-line runner for modular tests using TestItemRunner.jl

  This script provides a comprehensive interface to run TestItems.jl-based
  tests with filtering capabilities.

  Basic usage:
      julia --project=test test/runtests.jl                               # Run all test items
      julia --project=test test/runtests.jl --help                        # Show help
      julia --project=test test/runtests.jl --verbose                     # Run with verbose output
      julia --project=test test/runtests.jl --list-tags                   # List existing tags

  Filters (multiple can be passed, all must be satisfied):
      julia --project=test test/runtests.jl --file test-some-file.jl      # Run specific file
      julia --project=test test/runtests.jl --tags tag1,tags2             # Run tests matching both
      julia --project=test test/runtests.jl --name "Some test name"       # Run specific test by name
      julia --project=test test/runtests.jl --pattern "Some pattern"      # Run test names or files that match pattern
      julia --project=test test/runtests.jl --exclude tag1,tags2          # Exclude tests with any of the tags
  """
  return
end

function _list_available_tags()
  @info "Available tags for filtering tests:"
  println()

  for (tag, desc) in TAGS_DATA
    if isempty(desc)
      println("  $tag")
    else
      println("  $tag - $desc")
    end
  end

  return
end

const TAGS_DATA = Dict(
  # TODO: Make sure every test has some of these tags
  # Test Type (What kind of test?)
  :integration => "End-to-end tests with real datasets and full workflows",
  :unit => "Single component or function tests",
  :validation => "Tests verifying expected values, behavior, or mathematical correctness",

  # Complexity (How resource-intensive?)
  :fast => "Quick tests suitable for frequent execution",
  :slow => "Resource-intensive tests requiring significant time or memory",

  # Feature Areas (What functionality is being tested?)
  :test_strategy => "Tests for TestingStrategy functionality",
  :guessing => "Automatic data guessing functionality",
  :template_application => "Template application and generation",
  :copier_compatibility => "Compatibility with copier CLI",
  :license_handling => "License file creation and handling",
  :error_handling => "Error conditions and validation",
  :package_creation => "Package generation workflows",
  :update_workflow => "Template update functionality",

  # Test Characteristics (What capabilities/dependencies are required?)
  :file_io => "Tests involving file system operations",
  :git_operations => "Tests requiring git setup/operations",
  :python_integration => "Tests involving Python/copier integration",
  :randomized => "Tests using randomized inputs",
)

function main()
  args = parse_arguments()

  if args.help
    _print_help()
    return
  end

  if args.list
    _list_available_tags()
    return
  end

  println("Running Test Items")
  println("="^30)

  filter_func = _create_filter(args)
  test_project_toml_path = joinpath(@__DIR__, "Project.toml")

  mktempdir() do envdir
    cd(envdir) do
      # Copy test/Project.toml over to temporary folder
      cp(test_project_toml_path, joinpath(envdir, "Project.toml"))
      # `pkg> dev` the package
      Pkg.activate(envdir)
      Pkg.develop(; path = joinpath(@__DIR__, ".."))
      # Run the tests
      if isnothing(filter_func)
        @run_package_tests verbose = args.verbose
      else
        @run_package_tests verbose = args.verbose filter = filter_func
      end
    end
  end

  return
end

"""
    _parse_argument_with_value(flag, transform = identity)

Parse a command-line argument that expects a value.

# Arguments
- `flag`: The command-line flag to search for (e.g., "--file")
- `transform`: Function to transform the argument value (default: identity)

# Returns
- The transformed argument value if found, `nothing` otherwise

# Behavior
- If multiple occurrences exist, uses the last one (warns about duplicates)
- Follows Unix convention of "last wins"

# Throws
- Error if flag is present but no value follows
- Error if transformation fails
"""
function _parse_argument_with_value(flag, transform = identity)
  occurrences = findall(x -> x == flag, ARGS)
  isempty(occurrences) && return nothing

  if length(occurrences) > 1
    @warn "Duplicate argument '$flag' found, using last occurrence"
  end

  idx = last(occurrences)
  if idx == length(ARGS)
    error("Missing argument for '$flag'")
  end
  try
    return transform(ARGS[idx + 1])
  catch e
    error("Invalid value for flag '$flag': $(ARGS[idx + 1])")
  end
end

"""
    _validate_arguments()

Validate that all command-line arguments are recognized.

# Throws
- Error if any unrecognized arguments are found
"""
function _validate_arguments()
  valid_flags = Set([
    "--verbose",
    "-v",
    "--help",
    "-h",
    "--list-tags",
    "-l",
    "--file",
    "--tags",
    "--exclude",
    "--name",
    "--pattern",
  ])

  i = 1
  while i <= length(ARGS)
    arg = ARGS[i]
    if startswith(arg, "-")
      if !(arg in valid_flags)
        error("Unknown argument: $arg")
      end
      # Skip the next argument if this flag expects a value
      if arg in ["--file", "--tags", "--exclude", "--name", "--pattern"]
        i += 1  # Skip the value
      end
    end
    i += 1
  end
end

"""
    parse_arguments()

Parse command-line arguments for the test runner.

# Returns
A named tuple containing parsed arguments:
- `verbose`: Enable verbose test output (Bool)
- `help`: Show help message and exit (Bool)
- `list`: List available tags and exit (Bool)
- `file`: Run tests from files containing this substring (String or nothing)
- `tags`: Run tests that have ALL of these tags - AND logic (Vector{Symbol} or nothing)
- `exclude`: Skip tests that have ANY of these tags - OR logic (Vector{Symbol} or nothing)
- `name`: Run tests whose name contains this substring (String or nothing)
- `pattern`: Run tests whose name OR filename contains this substring (String or nothing)

# Filter Logic
All specified filters must pass (AND logic between different filter types).
For tags: ALL specified tags must be present on the test.
For exclude: ANY specified tag present will exclude the test.

# Notes
- Repeated arguments use "last wins" behavior with warnings
- Tags are validated against TAGS_DATA dictionary
"""
function parse_arguments()
  _validate_arguments()

  verbose = "--verbose" in ARGS || "-v" in ARGS
  help = "--help" in ARGS || "-h" in ARGS
  list = "--list-tags" in ARGS || "-l" in ARGS

  file_filter = _parse_argument_with_value("--file")
  name_filter = _parse_argument_with_value("--name")
  pattern_filter = _parse_argument_with_value("--pattern")

  function ensure_tag_existence(tag)
    if !haskey(TAGS_DATA, tag)
      error("Tag '$tag' is not a valid tag. Update `TAGS_DATA` in `test/runtests.jl` if necessary")
    end
    return tag
  end

  tag_transform(list_of_tags) =
    map(split(list_of_tags, ",")) do tag
      ensure_tag_existence(Symbol(tag))
    end

  tags_filter = _parse_argument_with_value("--tags", tag_transform)
  exclude_filter = _parse_argument_with_value("--exclude", tag_transform)

  return (
    verbose = verbose,
    help = help,
    list = list,
    file = file_filter,
    tags = tags_filter,
    exclude = exclude_filter,
    name = name_filter,
    pattern = pattern_filter,
  )
end

function _create_filter(args)
  filters = []

  # File filter
  if !isnothing(args.file)
    push!(filters, test_item -> contains(test_item.filename, args.file))
  end

  # Tags filter
  if !isnothing(args.tags)
    push!(filters, test_item -> all(tag in test_item.tags for tag in args.tags))
  end

  # Exclude filter
  if !isnothing(args.exclude)
    push!(filters, test_item -> !(any(tag in test_item.tags for tag in args.exclude)))
  end

  # Name filter
  if !isnothing(args.name)
    push!(filters, test_item -> contains(test_item.name, args.name))
  end

  # Pattern filter
  if !isnothing(args.pattern)
    push!(
      filters,
      test_item ->
        contains(test_item.name, args.pattern) || contains(test_item.filename, args.pattern),
    )
  end

  if isempty(filters)
    return nothing
  end

  # Combine all filters with AND logic
  return test_item -> all(f(test_item) for f in filters)
end

# Run only if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
  main()
else
  @run_package_tests verbose = true
end
