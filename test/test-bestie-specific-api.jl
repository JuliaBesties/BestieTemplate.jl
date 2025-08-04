@testsnippet ApiTestHelpers begin
  # Expected guessable data keys
  guessable_answers = Set([
    "Authors",
    "JuliaMinVersion",
    "JuliaIndentation",
    "PackageName",
    "PackageOwner",
    "PackageUUID",
  ])

  # Helper to test incomplete guessing scenarios - keeps complex setup/verification logic
  function test_incomplete_guessing(setup_action, missing_keys, debug_messages = [])
    src_data = copy(TestConstants.args.bestie.robust)
    expected_keys = setdiff(guessable_answers, missing_keys)

    _with_tmp_dir() do dir
      # Generate project normally first
      _generate_test_package(".", src_data)

      # Apply the setup action (e.g., remove files)
      setup_action()

      # Test guessing with debug logs
      if !isempty(debug_messages)
        @test_logs debug_messages... min_level=Logging.Debug BestieTemplate._read_data_from_existing_path(
          ".",
        )
      else
        BestieTemplate._read_data_from_existing_path(".")
      end

      # Verify expected data
      guessed_data = BestieTemplate._read_data_from_existing_path(".")
      for (key, value) in guessed_data
        @test value == src_data[key]
      end
      @test Set(keys(guessed_data)) == expected_keys
    end
  end
end

@testmodule GuessTestData begin
  # Pre-generated random test data for consistent testing
  const RANDOM_TEST_ITERATIONS = 10
  const INVALID_PACKAGE_NAMES = ["Bad.jl", "0Bad", "bad"]
end

@testitem "Automatic data guessing works with random inputs" tags =
  [:unit, :fast, :guessing, :randomized, :file_io] setup =
  [TestConstants, Common, ApiTestHelpers, GuessTestData] begin
  src_data = copy(TestConstants.args.bestie.robust)

  for _ in 1:GuessTestData.RANDOM_TEST_ITERATIONS
    # Randomize all data fields
    for (key, value) in src_data
      src_data[key] = _random(Val(Symbol(key)), value)
    end

    # Test data guessing functionality
    _with_tmp_dir() do dir
      _generate_test_package(".", src_data)

      # Test that guesses are correct
      guessed_data = BestieTemplate._read_data_from_existing_path(".")
      for (key, value) in guessed_data
        @test value == src_data[key]
      end
      # Test that expected keys were guessed
      @test Set(keys(guessed_data)) == guessable_answers
    end

    # Test that keyword guess=false ignores the guessed data
    _with_tmp_dir() do dir
      _generate_test_package(".", TestConstants.args.bestie.robust)
      rm(".copier-answers.yml")
      _git_setup()
      _apply_test_template(".", TestConstants.args.bestie.robust; guess = false)

      answers = YAML.load_file(".copier-answers.yml")
      guessed_data = BestieTemplate._read_data_from_existing_path(".")
      for (key, value) in guessed_data
        @test answers[key] == TestConstants.args.bestie.robust[key]
      end
    end
  end
end

@testitem "Incomplete guessing handles missing Project.toml" tags =
  [:unit, :fast, :guessing, :file_io] setup = [TestConstants, Common, ApiTestHelpers] begin
  # Test missing Project.toml file
  missing_keys = ["Authors", "JuliaMinVersion", "PackageName", "PackageUUID"]
  test_incomplete_guessing(() -> rm("Project.toml"), missing_keys, [(:debug, "No Project.toml")])

  # Test empty Project.toml file
  test_incomplete_guessing(
    () -> (rm("Project.toml"); touch("Project.toml")),
    missing_keys,
    [
      (:debug, "No key name in TOML"),
      (:debug, "No key uuid in TOML"),
      (:debug, "No authors information"),
      (:debug, "No compat information"),
    ],
  )
end

@testitem "Incomplete guessing handles missing docs/make.jl" tags =
  [:unit, :fast, :guessing, :file_io] setup = [TestConstants, Common, ApiTestHelpers] begin
  # Test missing docs/make.jl file
  missing_keys = ["PackageOwner"]
  test_incomplete_guessing(
    () -> rm("docs/make.jl"),
    missing_keys,
    [(:debug, "No file docs/make.jl")],
  )

  # Test empty docs/make.jl file
  test_incomplete_guessing(
    () -> (rm("docs/make.jl"); touch("docs/make.jl")),
    missing_keys,
    [(:debug, "No match for repo regex")],
  )
end

@testitem "Incomplete guessing handles missing .JuliaFormatter.toml" tags =
  [:unit, :fast, :guessing, :file_io] setup = [TestConstants, Common, ApiTestHelpers] begin
  # Test missing .JuliaFormatter.toml file
  missing_keys = ["JuliaIndentation"]
  test_incomplete_guessing(
    () -> rm(".JuliaFormatter.toml"),
    missing_keys,
    [(:debug, "No file .JuliaFormatter.toml")],
  )

  # Test empty .JuliaFormatter.toml file
  test_incomplete_guessing(
    () -> (rm(".JuliaFormatter.toml"); touch(".JuliaFormatter.toml")),
    missing_keys,
    [(:debug, "No indent found in .JuliaFormatter.toml")],
  )
end

@testitem "Template application works on existing projects" tags =
  [:unit, :fast, :template_application, :file_io, :git_operations] setup =
  [TestConstants, Common, ApiTestHelpers] begin
  _with_tmp_dir() do dir_existing
    _basic_new_pkg("NewPkg")
    _apply_test_template("NewPkg/", Dict("Authors" => "T. Esther", "PackageOwner" => "test"))

    _validate_copier_answers(
      Dict("PackageName" => "NewPkg", "Authors" => "T. Esther", "PackageOwner" => "test"),
      "NewPkg/.copier-answers.yml",
    )
  end
end

@testitem "Package name guessing works from directory path" tags =
  [:unit, :fast, :guessing, :file_io] setup = [TestConstants, Common, ApiTestHelpers] begin
  _with_tmp_dir() do dir_path_is_dir
    # Test automatic guessing from path
    data = _create_test_data(:robust; modifications = Dict("PackageName" => nothing))
    delete!(data, "PackageName")  # Remove PackageName to test path guessing
    mkdir("some_folder")
    _generate_test_package("some_folder/SomePackage1.jl", data)
    _validate_copier_answers(
      Dict("PackageName" => "SomePackage1"),
      "some_folder/SomePackage1.jl/.copier-answers.yml",
    )

    # Test explicit name overrides path guessing
    data_with_name = _create_test_data(:robust; modifications = Dict("PackageName" => "OtherName"))
    _generate_test_package("some_folder/SomePackage2.jl", data_with_name)
    _validate_copier_answers(
      Dict("PackageName" => "OtherName"),
      "some_folder/SomePackage2.jl/.copier-answers.yml",
    )
  end
end

@testitem "Invalid package names are properly rejected" tags =
  [:unit, :fast, :error_handling, :validation] setup =
  [TestConstants, Common, ApiTestHelpers, GuessTestData] begin
  for name in GuessTestData.INVALID_PACKAGE_NAMES
    _with_tmp_dir() do dir
      data = _create_test_data(:robust; modifications = Dict("PackageName" => name))
      @test_throws PythonCall.Core.PyException _generate_test_package(".", data)
    end
  end
end

@testitem "Apply validation rejects non-existent destination" tags =
  [:unit, :fast, :error_handling, :validation] setup = [TestConstants, Common, ApiTestHelpers] begin
  _with_tmp_dir() do dir
    @test_throws Exception BestieTemplate.apply("some_folder1", quiet = true)
  end
end

@testitem "Apply validation rejects destination without git" tags =
  [:unit, :fast, :error_handling, :validation] setup = [TestConstants, Common, ApiTestHelpers] begin
  _with_tmp_dir() do dir
    mkdir("some_folder2")
    @test_throws Exception BestieTemplate.apply("some_folder2", quiet = true)
  end
end

@testitem "Quick package creation works correctly" tags =
  [:unit, :fast, :package_creation, :file_io] setup = [TestConstants, Common, ApiTestHelpers] begin
  _with_tmp_dir() do dir
    BestieTemplate.new_pkg_quick("NewPkg.jl", "JuliaBesties", "JuliaBesties maintainers", :tiny)

    filename = joinpath("NewPkg.jl", "Project.toml")
    @test isfile(filename)

    toml = TOML.parsefile(filename)
    @test toml["authors"] == ["JuliaBesties maintainers"]
  end
end

# Don't run for branch main or tags
if get(ENV, "BESTIE_SKIP_UPDATE_TEST", "no") != "yes" &&
   chomp(read(`git branch --show-current`, String)) != "main" &&
   get(ENV, "GITHUB_REF_TYPE", "nothing") != "tag"
  @testitem "Update workflow produces same result as direct generation" tags =
    [:integration, :slow, :update_workflow, :git_operations, :file_io] setup =
    [TestConstants, Common, ApiTestHelpers] begin
    _with_tmp_dir() do dir
      common_args = (defaults = true, quiet = true)

      mkdir("gen_then_up")
      cd("gen_then_up") do
        # Generate the release version
        BestieTemplate.generate(
          TestConstants.template_path,
          ".",
          TestConstants.args.bestie.robust;
          vcs_ref = "main",
          common_args...,
        )
        _git_setup()
        _full_precommit()
        # Update using the HEAD version
        BestieTemplate.update(
          ".",
          TestConstants.args.bestie.robust;
          vcs_ref = "HEAD",
          common_args...,
        )
        _full_precommit()
      end

      mkdir("gen_direct")
      cd("gen_direct") do
        # Generate directly in the HEAD version
        BestieTemplate.generate(
          TestConstants.template_path,
          ".",
          TestConstants.args.bestie.robust;
          vcs_ref = "HEAD",
          common_args...,
        )
        _git_setup()
        _full_precommit()
      end

      _test_diff_dir("gen_then_up", "gen_direct")
    end
  end
end
