# This is only useful for testing offline. It creates a local env to avoid redownloading things.
ENV["JULIA_CONDAPKG_ENV"] = joinpath(@__DIR__, "conda-env")
if isdir(ENV["JULIA_CONDAPKG_ENV"])
  ENV["JULIA_CONDAPKG_OFFLINE"] = true
end

using COPIERTemplate
using Test

template_options = Dict(
  "PackageName" => "Tmp",
  "PackageUUID" => "1234",
  "PackageOwner" => "test",
  "AuthorName" => "Test",
  "AuthorEmail" => "test@me.now",
  "AskAdvancedQuestions" => true,
  "JuliaMinVersion" => "1.6",
  "License" => "MIT",
  "AddCodeOfConduct" => true,
  "Indentation" => "3",
  "AddMacToCI" => true,
  "AddWinToCI" => true,
  "RunJuliaNightlyOnCI" => true,
  "UseCirrusCI" => true,
)

function test_diff_dir(dir1, dir2)
  ignore(line) = startswith("_commit")(line) || startswith("_src_path")(line)
  @testset "$(basename(dir1)) vs $(basename(dir2))" begin
    for (root, _, files) in walkdir(dir1)
      nice_dir(file) =
        replace(root, dir1 => "") |> out -> replace(out, r"^/" => "") |> out -> joinpath(out, file)
      if nice_dir("") |> startswith(".git")
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

bash_args = vcat([["-d"; "$k=$v"] for (k, v) in template_options]...)
template_path = joinpath(@__DIR__, "..")

@testset "Compare COPIERTemplate.generate vs copier CLI on HEAD" begin
  mktempdir(; prefix = "cli_") do dir_copier_cli
    run(`copier copy --vcs-ref HEAD --quiet $bash_args $template_path $dir_copier_cli`)

    mktempdir(; prefix = "copy_") do tmpdir
      COPIERTemplate.generate(tmpdir; data = template_options, quiet = true, vcs_ref = "HEAD")
      test_diff_dir(tmpdir, dir_copier_cli)
    end
  end
end
