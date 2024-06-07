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

using COPIERTemplate
using Pkg
using Test
using YAML

template_minimum_options = Dict(
  "PackageName" => "Tmp",
  "PackageUUID" => "1234",
  "PackageOwner" => "test",
  "AuthorName" => "Test",
  "AuthorEmail" => "test@me.now",
)

template_options = Dict(
  "PackageName" => "Tmp",
  "PackageUUID" => "1234",
  "PackageOwner" => "test",
  "AuthorName" => "Test",
  "AuthorEmail" => "test@me.now",
  "AskAdvancedQuestions" => true,
  "AddAllcontributors" => true,
  "JuliaMinVersion" => "1.6",
  "License" => "MIT",
  "AddCodeOfConduct" => true,
  "Indentation" => "3",
  "AddMacToCI" => true,
  "AddWinToCI" => true,
  "RunJuliaNightlyOnCI" => true,
  "SimplifiedPRTest" => true,
  "UseCirrusCI" => true,
  "AddPrecommit" => true,
)

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

min_bash_args = vcat([["-d"; "$k=$v"] for (k, v) in template_minimum_options]...)
bash_args = vcat([["-d"; "$k=$v"] for (k, v) in template_options]...)
template_path = joinpath(@__DIR__, "..")
template_url = "https://github.com/abelsiqueira/COPIERTemplate.jl"

# This is a hack because Windows managed to dirty the repo.
if get(ENV, "CI", "nothing") == "true" && Sys.iswindows()
  run(`git reset --hard HEAD`)
end

@testset "Compare COPIERTemplate.generate vs copier CLI on URL/main" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref main --quiet $bash_args $template_url $dir_copier_cli`)

    mktempdir(TMPDIR; prefix = "copy_") do tmpdir
      COPIERTemplate.generate(tmpdir, template_options; quiet = true, vcs_ref = "main")
      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end

@testset "Compare COPIERTemplate.generate vs copier CLI on HEAD" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref HEAD --quiet $bash_args $template_path $dir_copier_cli`)

    mktempdir(TMPDIR; prefix = "copy_") do tmpdir
      COPIERTemplate.generate(
        template_path,
        tmpdir,
        template_options;
        quiet = true,
        vcs_ref = "HEAD",
      )
      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end

@testset "Testing copy, recopy and rebase" begin
  mktempdir(TMPDIR; prefix = "cli_") do dir_copier_cli
    run(`copier copy --quiet $bash_args $template_path $dir_copier_cli`)

    @testset "Compare copied project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "copy_") do tmpdir
        COPIERTemplate.Copier.copy(tmpdir, template_options; quiet = true)
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end

    @testset "Compare recopied project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "recopy_") do tmpdir
        run(`copier copy --defaults --quiet $min_bash_args $template_path $tmpdir`)
        COPIERTemplate.Copier.recopy(tmpdir, template_options; quiet = true, overwrite = true)
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end

    @testset "Compare updated project vs copier CLI baseline" begin
      mktempdir(TMPDIR; prefix = "update_") do tmpdir
        run(`copier copy --defaults --quiet $min_bash_args $template_path $tmpdir`)
        cd(tmpdir) do
          run(`git init`)
          run(`git add .`)
          run(`git config user.name "Test"`)
          run(`git config user.email "test@test.com"`)
          run(`git commit -q -m "First commit"`)
        end
        COPIERTemplate.Copier.update(tmpdir, template_options; overwrite = true, quiet = true)
        test_diff_dir(tmpdir, dir_copier_cli)
      end
    end
  end
end

@testset "Test generating the template on an existing project" begin
  mktempdir(TMPDIR; prefix = "existing_") do dir_existing
    cd(dir_existing) do
      Pkg.generate("NewPkg")
      COPIERTemplate.generate(
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
        data = Dict(key => value for (key, value) in template_options if key != "PackageName")
        mkdir("some_folder")
        COPIERTemplate.generate(
          template_path,
          "some_folder/SomePackage1.jl",
          data;
          quiet = true,
          vcs_ref = "HEAD",
        )
        answers = YAML.load_file("some_folder/SomePackage1.jl/.copier-answers.yml")
        @test answers["PackageName"] == "SomePackage1"
        COPIERTemplate.generate(
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
end
