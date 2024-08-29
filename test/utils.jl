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
        replace(root, dir1 => "") |> out -> replace(out, r"^/" => "") |> out -> joinpath(out, file)
      if nice_dir("") |> x -> occursin(r"[\\/]?git[\\/]+", x)
        continue
      end

      @testset "File $(nice_dir(file))" for file in files
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
_random(::Val{:AnswerStrategy}, value) = rand(["minimum", "recommended", "ask"])
_random(::Val{:License}, value) = rand(["Apache-2.0", "GPL-3.0", "MIT", "MPL-2.0"])
_random(::Val{:Indentation}, value) = rand(2:8)
_random(::Val{:PackageUUID}, value) = [x in C.hex ? rand(C.hex) : x for x in value] |> join
_random(::Val{:JuliaMinVersion}, value) = "1.$(rand(0:20))"
_random(::Val{:JuliaMinCIVersion}, value) = rand() < 0.2 ? "lts" : "1.$(rand(0:20))"

"""
Constants used in the tests
"""
module C

using BestieTemplate.Debug.Data: Data

"Transforms the dict 'k => v' into copier args '-d k=v'"
_bestie_args_to_copier_args(dict) = vcat([["-d"; "$k=$v"] for (k, v) in dict]...)

"Arguments for the different calls"
_bestie_args = (min = Data.strategy_minimum, ask = Data.strategy_ask_default)
args = (
  bestie = _bestie_args,
  copier = NamedTuple(
    key => _bestie_args_to_copier_args(value) for (key, value) in pairs(_bestie_args)
  ),
)

template_path = joinpath(@__DIR__, "..")
template_url = "https://github.com/abelsiqueira/BestieTemplate.jl"

lowercase_letters = 'a':'z'
uppercase_letters = 'A':'Z'
letters = lowercase_letters ∪ uppercase_letters
digits = '0':'9'
hex = digits ∪ ('a':'f')

end
