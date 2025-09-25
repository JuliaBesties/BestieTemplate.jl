# Test constants and expensive one-time computations
@testmodule TestConstants begin
  using BestieTemplate.Debug.Data: Data

  "Transforms the dict 'k => v' into copier args '-d k=v'"
  _bestie_args_to_copier_args(dict) = vcat([["-d"; "$k=$v"] for (k, v) in dict]...)

  "Arguments for the different calls"
  const args = (
    bestie = Data.strategies,
    copier = NamedTuple(
      key => _bestie_args_to_copier_args(value) for (key, value) in pairs(Data.strategies)
    ),
  )

  const template_path = joinpath(@__DIR__, "..")
  const template_url = "https://github.com/JuliaBesties/BestieTemplate.jl"

  const lowercase_letters = 'a':'z'
  const uppercase_letters = 'A':'Z'
  const letters = lowercase_letters ∪ uppercase_letters
  const digits = '0':'9'
  const hex = digits ∪ ('a':'f')
end

@testsnippet Common begin
  # === ENVIRONMENT SETUP ===
  if get(ENV, "CI", "nothing") == "nothing"
    # This is only useful for testing offline. It creates a local env to avoid redownloading things.
    ENV["JULIA_CONDAPKG_ENV"] = joinpath(@__DIR__, "conda-env")
    if isdir(ENV["JULIA_CONDAPKG_ENV"])
      ENV["JULIA_CONDAPKG_OFFLINE"] = true
    end
  end

  # This is a hack because Windows managed to dirty the repo.
  if get(ENV, "CI", "nothing") == "true" && Sys.iswindows()
    run(`git reset --hard HEAD`)
  end

  # === IMPORTS ===
  using BestieTemplate
  using Logging
  using Pkg
  using PythonCall
  using Test
  using TOML
  using YAML

  # === CONSTANTS ACCESS ===
  # Note: Tests access TestConstants directly (testmodules cannot be aliased in testsnippets)

  # === GIT OPERATIONS ===
  function _git_setup()
    run(`git init -q`)
    run(`git add .`)
    run(`git config user.name "Test"`)
    run(`git config user.email "test@test.com"`)
    run(`git commit -q -m "First commit"`)
  end

  function _precommit()
    try
      read(`pre-commit run -a`) # run and ignore output
    catch
      nothing
    end
  end

  function _full_precommit()
    run(`git add .`)
    _precommit()
    run(`git add .`)
    try
      read(`git diff-index --exit-code HEAD`)
      return # No commit necessary, exit now (consequence of pre-commit passing for default values)
    catch
      nothing
    end
    run(`git commit -q -m "git add . and pre-commit run -a"`)
  end

  # === DIRECTORY & FILE OPERATIONS ===
  function _with_tmp_dir(f, args...; kwargs...)
    # Can't use mktempdir on GitHub actions willy nilly (at least on Mac)
    tmpdir = get(ENV, "TMPDIR", mktempdir())
    # Mac is a complicated beast
    if Sys.isapple() && get(ENV, "CI", "nothing") == "nothing"
      tmpdir = "/private$tmpdir"
    end

    mktempdir(tmpdir, args...; kwargs...) do x
      cd(x) do
        f(x)
      end
    end
  end

  function _basic_new_pkg(pkgname; run_git = true)
    Pkg.generate(pkgname)
    if run_git
      cd(pkgname) do
        _git_setup()
      end
    end
  end

  """
  Create a non-empty directory with content (for error testing)
  """
  function _create_non_empty_dir(dirname, filename = "README.md", content = "Hi")
    mkdir(dirname)
    open(joinpath(dirname, filename), "w") do io
      println(io, content)
    end
  end

  # === TESTING & VALIDATION UTILITIES ===
  function _test_diff_dir(dir1, dir2)
    ignore(line) = startswith("_commit")(line) || startswith("_src_path")(line)
    @testset "$(basename(dir1)) vs $(basename(dir2))" begin
      for (root, _, files) in walkdir(dir1)
        if contains("node_modules")(root)
          continue
        end

        nice_dir(file) =
          replace(root, dir1 => "") |>
          out -> replace(out, r"^/" => "") |> out -> joinpath(out, file)
        if nice_dir("") |> x -> occursin(r"[\\/]?git[\\/]+", x)
          continue
        end

        @testset "File $(nice_dir(file))" for file in files
          if endswith(".rej")(file)
            continue
          end
          file1 = joinpath(root, file)
          file2 = replace(file1, dir1 => dir2)
          lines1 = readlines(file1)
          lines2 = readlines(file2)
          equal = true
          for (line1, line2) in zip(lines1, lines2)
            ignore(line1) && continue
            @test line1 == line2
            if line1 != line2
              equal = false
            end
          end
          if !equal
            @warn "Different files on test:"
            @warn "File1:" lines1
            @warn "File2:" lines2
          end
        end
      end
    end
  end

  """
  Validate copier answers file against expected data
  """
  function _validate_copier_answers(expected_data, file_path = ".copier-answers.yml")
    answers = YAML.load_file(file_path)
    for (key, expected_value) in expected_data
      @test answers[key] == expected_value
    end
    return answers
  end

  # === RANDOM DATA GENERATION ===
  _random(::Val{T}, value) where {T} = rand(TestConstants.letters, length(value)) |> join
  _random(::Val{T}, value::Bool) where {T} = rand(Bool)
  _random(::Val{:PackageName}, value) =
    return "Pkg" * join(rand(TestConstants.letters, length(value) - 3))
  _random(::Val{:StrategyLevel}, value) = rand(0:3)
  _random(::Val{:License}, value) = rand(["Apache-2.0", "GPL-3.0", "MIT", "MPL-2.0"])
  _random(::Val{:Indentation}, value) = rand(2:8)
  _random(::Val{:JuliaIndentation}, value) = rand(2:8)
  _random(::Val{:MarkdownIndentation}, value) = rand(2:8)
  _random(::Val{:ConfigIndentation}, value) = rand(2:8)
  _random(::Val{:PackageUUID}, value) =
    [x in TestConstants.hex ? rand(TestConstants.hex) : x for x in value] |> join
  _random(::Val{:JuliaMinVersion}, value) = "1.$(rand(0:20))"
  _random(::Val{:JuliaMinCIVersion}, value) = rand() < 0.2 ? "lts" : "1.$(rand(0:20))"
  _random(::Val{:AddDocs}, value::Bool) = true
  _random(::Val{:AddFormatterAndLinterConfigFiles}, value::Bool) = true
  _random(::Val{:StrategyConfirmIncluded}, value::Bool) = true
  _random(::Val{:StrategyReviewExcluded}, value::Bool) = true
  _random(::Val{:TestingStrategy}, value) =
    rand(["basic", "testitem_cli", "testitem_basic", "basic_auto_discover"])

  # === DATA CREATION UTILITIES ===
  """
  Create test data with optional modifications
  """
  function _create_test_data(base = :robust; modifications = Dict())
    base_data = getfield(TestConstants.args.bestie, base)
    return merge(copy(base_data), modifications)
  end

  # === BESTIETEMPLATE OPERATIONS ===
  """
  Generate a test package with standard defaults
  """
  function _generate_test_package(
    destination = ".",
    data = TestConstants.args.bestie.robust;
    kwargs...,
  )
    defaults = (; quiet = true, vcs_ref = "HEAD")
    BestieTemplate.generate(
      TestConstants.template_path,
      destination,
      data;
      merge(defaults, kwargs)...,
    )
  end

  """
  Apply template with standard defaults
  """
  function _apply_test_template(destination, data = Dict(); kwargs...)
    defaults = (; defaults = true, overwrite = true, quiet = true, vcs_ref = "HEAD")
    BestieTemplate.apply(TestConstants.template_path, destination, data; merge(defaults, kwargs)...)
  end

  """
  Generate package with git setup and optional precommit
  """
  function _generate_with_git_setup(
    destination = ".",
    data = TestConstants.args.bestie.robust;
    run_precommit = true,
    kwargs...,
  )
    _generate_test_package(destination, data; kwargs...)
    _git_setup()
    if run_precommit
      _full_precommit()
    end
  end
end
