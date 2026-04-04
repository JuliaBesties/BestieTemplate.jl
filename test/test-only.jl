@testitem "only_testitem_cli updates runtests.jl to testitem_cli" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    # Generate a tiny package (TestingStrategy = "basic")
    _generate_test_package(".", TestConstants.args.bestie.tiny; defaults = true)

    # Snapshot all files (skip .git internals)
    snapshot = Dict{String, Vector{UInt8}}()
    for (root, _, files) in walkdir(".")
      contains(root, ".git") && continue
      for file in files
        path = relpath(joinpath(root, file))
        snapshot[path] = read(path)
      end
    end

    # Verify basic strategy initially (no testitem_cli markers)
    runtests_path = joinpath("test", "runtests.jl")
    runtests_before = String(snapshot[runtests_path])
    @test !contains(runtests_before, "TAGS_DATA")
    @test !contains(runtests_before, "parse_arguments")

    # Switch to testitem_cli
    BestieTemplate.only_testitem_cli(
      ".";
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )

    # Verify test/runtests.jl now has testitem_cli content
    runtests_after = read(runtests_path, String)
    @test runtests_after != runtests_before
    @test contains(runtests_after, "TAGS_DATA")
    @test contains(runtests_after, "parse_arguments")

    # Verify .copier-answers.yml was updated with testitem_cli strategy
    _validate_copier_answers(Dict("TestingStrategy" => "testitem_cli"))

    # Verify no other files changed (copier always rewrites .copier-answers.yml)
    answers_path = ".copier-answers.yml"
    for (path, old_content) in snapshot
      path in (runtests_path, answers_path) && continue
      @test isfile(path)
      @test read(path) == old_content
    end
  end
end

@testitem "only(:testitem_cli, ...) works via generic API" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.tiny; defaults = true)

    runtests_path = joinpath("test", "runtests.jl")
    runtests_before = read(runtests_path, String)
    @test !contains(runtests_before, "TAGS_DATA")

    BestieTemplate.only(
      :testitem_cli,
      ".";
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )

    runtests_after = read(runtests_path, String)
    @test contains(runtests_after, "TAGS_DATA")
    @test contains(runtests_after, "parse_arguments")
  end
end

@testitem "only_testitem_cli works without .copier-answers.yml when data is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    # Use light strategy so docs/make.jl exists and PackageOwner can be guessed
    _generate_test_package(".", TestConstants.args.bestie.light; defaults = true)
    rm(".copier-answers.yml")

    BestieTemplate.only_testitem_cli(
      ".";
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )

    # .copier-answers.yml should NOT be created when it didn't exist before
    @test !isfile(".copier-answers.yml")
    @test contains(read(joinpath("test", "runtests.jl"), String), "TAGS_DATA")
  end
end

@testitem "only data argument overrides guessed and answers data" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.tiny; defaults = true)

    custom_owner = "CustomOwnerForTest"
    BestieTemplate.only(
      :testitem_cli,
      ".",
      Dict("PackageOwner" => custom_owner);
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )

    answers = _validate_copier_answers(Dict("TestingStrategy" => "testitem_cli"))
    @test answers["PackageOwner"] == custom_owner
  end
end

@testitem "only with explicit data rescues missing fields" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")

    # No Project.toml, no docs — but explicit data provides required fields
    BestieTemplate.only(
      :testitem_cli,
      ".",
      Dict("PackageName" => "RescuePkg", "PackageOwner" => "rescuer", "Authors" => "Test Author");
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )

    @test contains(read(joinpath("test", "runtests.jl"), String), "TAGS_DATA")
    # No .copier-answers.yml should be created
    @test !isfile(".copier-answers.yml")
  end
end

# TODO: When a feature with required fields is added (e.g. :pre_commit), add an error test here
@testitem "only_testitem_cli succeeds without data when feature has no required fields" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")

    # testitem_cli requires no fields, so this should work with placeholders
    BestieTemplate.only_testitem_cli(
      ".";
      template_source = :local,
      local_template_path = TestConstants.template_path,
    )
    @test contains(read(joinpath("test", "runtests.jl"), String), "TAGS_DATA")
    @test !isfile(".copier-answers.yml")
  end
end

@testitem "only works without required fields when feature files don't need them" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [TestConstants, Common] begin
  # testitem_cli's test/runtests.jl doesn't reference PackageName/PackageOwner/Authors,
  # so in principle it should work without them. Currently errors because the required
  # fields check is unconditional. This test documents the desired future behavior.
  _with_tmp_dir() do dir
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")

    succeeded = try
      BestieTemplate.only(
        :testitem_cli,
        ".";
        template_source = :local,
        local_template_path = TestConstants.template_path,
      )
      true
    catch
      false
    end
    @test succeeded
  end
end
