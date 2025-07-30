# TODO: This should be split better
@testsnippet Common begin
  # Can't use mktempdir on GitHub actions willy nilly (at least on Mac)
  if get(ENV, "CI", "nothing") == "nothing"
    # This is only useful for testing offline. It creates a local env to avoid redownloading things.
    ENV["JULIA_CONDAPKG_ENV"] = joinpath(@__DIR__, "conda-env")
    @info ENV["JULIA_CONDAPKG_ENV"]
    if isdir(ENV["JULIA_CONDAPKG_ENV"])
      ENV["JULIA_CONDAPKG_OFFLINE"] = true
    end
  end

  # This is a hack because Windows managed to dirty the repo.
  if get(ENV, "CI", "nothing") == "true" && Sys.iswindows()
    run(`git reset --hard HEAD`)
  end

  using BestieTemplate
  using Logging
  using Pkg
  using PythonCall
  using Test
  using TOML
  using YAML

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
          for (line1, line2) in zip(lines1, lines2)
            ignore(line1) && continue
            @test line1 == line2
          end
        end
      end
    end
  end

  _random(::Val{T}, value) where {T} = rand(C.letters, length(value)) |> join
  _random(::Val{T}, value::Bool) where {T} = rand(Bool)
  _random(::Val{:PackageName}, value) = return "Pkg" * join(rand(C.letters, length(value) - 3))
  _random(::Val{:StrategyLevel}, value) = rand(0:3)
  _random(::Val{:License}, value) = rand(["Apache-2.0", "GPL-3.0", "MIT", "MPL-2.0"])
  _random(::Val{:Indentation}, value) = rand(2:8)
  _random(::Val{:JuliaIndentation}, value) = rand(2:8)
  _random(::Val{:MarkdownIndentation}, value) = rand(2:8)
  _random(::Val{:ConfigIndentation}, value) = rand(2:8)
  _random(::Val{:PackageUUID}, value) = [x in C.hex ? rand(C.hex) : x for x in value] |> join
  _random(::Val{:JuliaMinVersion}, value) = "1.$(rand(0:20))"
  _random(::Val{:JuliaMinCIVersion}, value) = rand() < 0.2 ? "lts" : "1.$(rand(0:20))"
  _random(::Val{:AddDocs}, value::Bool) = true
  _random(::Val{:AddFormatterAndLinterConfigFiles}, value::Bool) = true
  _random(::Val{:StrategyConfirmIncluded}, value::Bool) = true
  _random(::Val{:StrategyReviewExcluded}, value::Bool) = true

  """
  Constants used in the tests
  """
  module C

  using BestieTemplate.Debug.Data: Data

  "Transforms the dict 'k => v' into copier args '-d k=v'"
  _bestie_args_to_copier_args(dict) = vcat([["-d"; "$k=$v"] for (k, v) in dict]...)

  "Arguments for the different calls"
  _bestie_args =
    args = (
      bestie = Data.strategies,
      copier = NamedTuple(
        key => _bestie_args_to_copier_args(value) for (key, value) in pairs(Data.strategies)
      ),
    )

  template_path = joinpath(@__DIR__, "..")
  template_url = "https://github.com/JuliaBesties/BestieTemplate.jl"

  lowercase_letters = 'a':'z'
  uppercase_letters = 'A':'Z'
  letters = lowercase_letters ∪ uppercase_letters
  digits = '0':'9'
  hex = digits ∪ ('a':'f')

  end
end
