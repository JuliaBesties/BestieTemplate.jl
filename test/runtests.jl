# Can't use mktempdir on GitHub actions willy nilly (at least on Mac)
TMPDIR = get(ENV, "TMPDIR", mktempdir())

if get(ENV, "CI", "nothing") == "nothing"
  # This is only useful for testing offline. It creates a local env to avoid redownloading things.
  ENV["JULIA_CONDAPKG_ENV"] = joinpath(@__DIR__, "conda-env")
  if isdir(ENV["JULIA_CONDAPKG_ENV"])
    ENV["JULIA_CONDAPKG_OFFLINE"] = true
  end

  # Mac is a complicated beast
  if Sys.isapple()
    TMPDIR = "/private$TMPDIR"
  end
end

using BestieTemplate
using BestieTemplate.Debug.Data: Data
using Pkg
using PythonCall
using Test
using YAML

function _git_setup()
  run(`git init -q`)
  run(`git add .`)
  run(`git config user.name "Test"`)
  run(`git config user.email "test@test.com"`)
  run(`git commit -q -m "First commit"`)
end

function test_diff_dir(dir1, dir2)
  ignore(line) = startswith("_commit")(line) || startswith("_src_path")(line)
  @testset "$(basename(dir1)) vs $(basename(dir2))" begin
    for (root, _, files) in walkdir(dir1)
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

data_to_cli_args(dict) = vcat([["-d"; "$k=$v"] for (k, v) in dict]...)
cli_args_min_defaults = data_to_cli_args(Data.minimum_defaults)
cli_args_strat_ask = data_to_cli_args(Data.strategy_ask_default)

template_path = joinpath(@__DIR__, "..")
template_url = "https://github.com/abelsiqueira/BestieTemplate.jl"

# This is a hack because Windows managed to dirty the repo.
if get(ENV, "CI", "nothing") == "true" && Sys.iswindows()
  run(`git reset --hard HEAD`)
end

@testset "Compare BestieTemplate.generate vs copier CLI on URL/main" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref main --quiet $cli_args_strat_ask $template_url $dir_copier_cli`)

    mktempdir(TMPDIR; prefix = "copy_") do tmpdir
      BestieTemplate.generate(tmpdir, Data.strategy_ask_default; quiet = true, vcs_ref = "main")
      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end

@testset "Compare BestieTemplate.generate vs copier CLI on HEAD" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref HEAD --quiet $cli_args_strat_ask $template_path $dir_copier_cli`)

    mktempdir(TMPDIR; prefix = "copy_") do tmpdir
      BestieTemplate.generate(
        template_path,
        tmpdir,
        Data.strategy_ask_default;
        quiet = true,
        vcs_ref = "HEAD",
      )
      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end

@testset "Compare BestieTemplate.update vs copier CLI update" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --defaults --quiet $cli_args_min_defaults $template_url $dir_copier_cli`)
    cd(dir_copier_cli) do
      _git_setup()
    end
    run(`copier update --defaults --quiet $cli_args_strat_ask $dir_copier_cli`)

    mktempdir(TMPDIR; prefix = "update_") do tmpdir
      BestieTemplate.generate(tmpdir, Data.minimum_defaults; defaults = true, quiet = true)
      cd(tmpdir) do
        _git_setup()
        BestieTemplate.update(Data.strategy_ask_default; defaults = true, quiet = true)
      end

      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end

@testset "Test that BestieTemplate.generate warns and exits for existing copy" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref HEAD --quiet $cli_args_strat_ask $template_url $dir_copier_cli`)
    cd(dir_copier_cli) do
      _git_setup()
    end

    @test_logs (:warn,) BestieTemplate.apply(dir_copier_cli; quiet = true)
  end
end

@testset "Test that generate fails for existing non-empty paths" begin
  mktempdir(TMPDIR) do dir
    cd(dir) do
      @testset "It fails if the dst_path exists and is non-empty" begin
        mkdir("some_folder1")
        open(joinpath("some_folder1", "README.md"), "w") do io
          println(io, "Hi")
        end
        @test_throws Exception BestieTemplate.generate("some_folder1")
      end

      @testset "It works if the dst_path is ." begin
        mkdir("some_folder2")
        cd("some_folder2") do
          # Should not throw
          BestieTemplate.generate(
            template_path,
            ".",
            Data.strategy_ask_default;
            quiet = true,
            vcs_ref = "HEAD",
          )
        end
      end

      @testset "It works if the dst_path exists but is empty" begin
        mkdir("some_folder3")
        # Should not throw
        BestieTemplate.generate(
          template_path,
          "some_folder3",
          Data.strategy_ask_default;
          quiet = true,
          vcs_ref = "HEAD",
        )
      end
    end
  end
end

@testset "Testing copy, recopy and rebase" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref HEAD --quiet $cli_args_strat_ask $template_path $dir_copier_cli`)

    @testset "Compare copied project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "copy_") do tmpdir
        BestieTemplate.Copier.copy(
          tmpdir,
          Data.strategy_ask_default;
          quiet = true,
          vcs_ref = "HEAD",
        )
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end

    @testset "Compare recopied project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "recopy_") do tmpdir
        run(
          `copier copy --vcs-ref HEAD --defaults --quiet $cli_args_min_defaults $template_path $tmpdir`,
        )
        BestieTemplate.Copier.recopy(
          tmpdir,
          Data.strategy_ask_default;
          quiet = true,
          overwrite = true,
          vcs_ref = "HEAD",
        )
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end

    @testset "Compare updated project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "update_") do tmpdir
        run(`copier copy --defaults --quiet $cli_args_min_defaults $template_path $tmpdir`)
        cd(tmpdir) do
          _git_setup()
        end
        BestieTemplate.Copier.update(
          tmpdir,
          Data.strategy_ask_default;
          overwrite = true,
          quiet = true,
          vcs_ref = "HEAD",
        )
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end
  end
end

@testset "Test applying the template on an existing project" begin
  mktempdir(TMPDIR; prefix = "existing_") do dir_existing
    cd(dir_existing) do
      Pkg.generate("NewPkg")
      cd("NewPkg") do
        _git_setup()
      end
      BestieTemplate.apply(
        template_path,
        "NewPkg/",
        Dict("AuthorName" => "T. Esther", "PackageOwner" => "test");
        defaults = true,
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      answers = YAML.load_file("NewPkg/.copier-answers.yml")
      @test answers["PackageName"] == "NewPkg"
      @test answers["AuthorName"] == "T. Esther"
      @test answers["PackageOwner"] == "test"
    end
  end

  @testset "Test automatic guessing the package name from the path" begin
    mktempdir(TMPDIR; prefix = "path_is_dir_") do dir_path_is_dir
      cd(dir_path_is_dir) do
        data =
          Dict(key => value for (key, value) in Data.strategy_ask_default if key != "PackageName")
        mkdir("some_folder")
        BestieTemplate.generate(
          template_path,
          "some_folder/SomePackage1.jl",
          data;
          quiet = true,
          vcs_ref = "HEAD",
        )
        answers = YAML.load_file("some_folder/SomePackage1.jl/.copier-answers.yml")
        @test answers["PackageName"] == "SomePackage1"
        BestieTemplate.generate(
          template_path,
          "some_folder/SomePackage2.jl",
          merge(data, Dict("PackageName" => "OtherName"));
          quiet = true,
          vcs_ref = "HEAD",
        )
        answers = YAML.load_file("some_folder/SomePackage2.jl/.copier-answers.yml")
        @test answers["PackageName"] == "OtherName"
      end
    end
  end

  @testset "Test that bad PackageName gets flagged" begin
    mktempdir(TMPDIR; prefix = "valid_pkg_name_") do dir
      cd(dir) do
        for name in ["Bad.jl", "0Bad", "bad"]
          data = copy(Data.strategy_ask_default)
          data["PackageName"] = name
          @test_throws PythonCall.Core.PyException BestieTemplate.generate(
            template_path,
            ".",
            data,
            quiet = true,
            vcs_ref = "HEAD",
          )
        end
      end
    end
  end

  @testset "Test input validation of apply" begin
    mktempdir(TMPDIR) do dir
      cd(dir) do
        @testset "It fails if the dst_path does not exist" begin
          @test_throws Exception BestieTemplate.apply("some_folder1", quiet = true)
        end

        @testset "It fails if the dst_path exists but does not contains .git" begin
          mkdir("some_folder2")
          @test_throws Exception BestieTemplate.apply("some_folder2", quiet = true)
        end
      end
    end
  end
end
