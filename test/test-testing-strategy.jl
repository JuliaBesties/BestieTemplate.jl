# Tests for the new TestingStrategy question functionality
# These tests complement the existing TestGeneratedPkg.yml workflow which already
# tests that generated packages build and run successfully.

@testsnippet StrategyTestHelpers begin
  # Expected dependency matrix based on template changes
  expected_deps = Dict(
    "basic" => Set(["Test", "TOML"]),
    "testitem_cli" => Set(["Pkg", "Test", "TestItems", "TestItemRunner", "TOML"]),
    "testitem_basic" => Set(["Test", "TestItems", "TestItemRunner", "TOML"]),
    "basic_auto_discover" => Set(["Test", "TOML"]),
  )

  # Expected defaults based on Data.jl values
  expected_defaults = Dict(
    "tiny" => "basic",
    "light" => "testitem_basic",
    "moderate" => "testitem_basic",  # inherits from light
    "robust" => "testitem_basic",     # inherits from moderate
  )

  # Helper function to detect TestingStrategy from generated content
  function detect_strategy_from_content(runtests_content, test_dir)
    if contains(runtests_content, "TAGS_DATA") && contains(runtests_content, "parse_arguments")
      return "testitem_cli"
    elseif contains(runtests_content, "@run_package_tests") &&
           contains(runtests_content, "TestItemRunner")
      return "testitem_basic"
    elseif contains(runtests_content, "walkdir") && contains(runtests_content, "test-.*\\.jl")
      return "basic_auto_discover"
    elseif contains(runtests_content, "@testset") &&
           !contains(runtests_content, "@run_package_tests")
      return "basic"
    else
      error("Could not detect TestingStrategy from content")
    end
  end

  # Common test logic for a specific strategy
  function test_strategy_complete(strategy, base_data, template_path)
    _with_tmp_dir() do dir
      # Create test data with specific strategy
      test_data = merge(base_data, Dict("TestingStrategy" => strategy))

      # Generate package
      BestieTemplate.generate(
        template_path,
        ".",
        test_data;
        defaults = true,
        quiet = true,
        vcs_ref = "HEAD",
      )

      # Test 1: Verify core files exist
      @test isfile("test/Project.toml")
      @test isfile("test/runtests.jl")

      # Test 2: Verify dependencies are correct
      project_toml = TOML.parsefile("test/Project.toml")
      @test haskey(project_toml, "deps")
      actual_deps = Set(keys(project_toml["deps"]))
      expected = expected_deps[strategy]
      @test actual_deps == expected
      @test "Test" in actual_deps  # Always present

      # Test 3: Verify file content and structure
      runtests_content = read("test/runtests.jl", String)
      detected_strategy = detect_strategy_from_content(runtests_content, "test")
      @test detected_strategy == strategy

      # Test 4: Check for additional test files based on strategy
      has_test_file = isfile("test/test-basic-test.jl")

      return (runtests_content, has_test_file)
    end
  end
end

@testitem "TestingStrategy basic works correctly" tags = [:unit, :fast, :test_strategy] setup =
  [TestConstants, Common, StrategyTestHelpers] begin
  runtests_content, has_test_file =
    test_strategy_complete("basic", TestConstants.args.bestie.tiny, TestConstants.template_path)

  # Strategy-specific validations
  @test contains(runtests_content, "@testset")
  @test !contains(runtests_content, "@run_package_tests")
  @test !contains(runtests_content, "TestItems")
  @test !contains(runtests_content, "TestItemRunner")

  # Should not have additional test files
  @test !has_test_file
end

@testitem "TestingStrategy testitem_cli works correctly" tags = [:unit, :fast, :test_strategy] setup =
  [TestConstants, Common, StrategyTestHelpers] begin
  runtests_content, has_test_file = test_strategy_complete(
    "testitem_cli",
    TestConstants.args.bestie.tiny,
    TestConstants.template_path,
  )

  # Strategy-specific validations
  @test contains(runtests_content, "@run_package_tests")
  @test contains(runtests_content, "TAGS_DATA")
  @test contains(runtests_content, "parse_arguments")
  @test contains(runtests_content, "_print_help")

  # Should not have additional test files (CLI handles everything)
  @test has_test_file
end

@testitem "TestingStrategy testitem_basic works correctly" tags = [:unit, :fast, :test_strategy] setup =
  [TestConstants, Common, StrategyTestHelpers] begin
  runtests_content, has_test_file = test_strategy_complete(
    "testitem_basic",
    TestConstants.args.bestie.tiny,
    TestConstants.template_path,
  )

  # Strategy-specific validations
  @test contains(runtests_content, "@run_package_tests")
  @test contains(runtests_content, "TestItemRunner")
  @test !contains(runtests_content, "TAGS_DATA")
  @test !contains(runtests_content, "parse_arguments")

  # Should have additional test file for testitems
  @test has_test_file
end

@testitem "TestingStrategy basic_auto_discover works correctly" tags =
  [:unit, :fast, :test_strategy] setup = [TestConstants, Common, StrategyTestHelpers] begin
  runtests_content, has_test_file = test_strategy_complete(
    "basic_auto_discover",
    TestConstants.args.bestie.tiny,
    TestConstants.template_path,
  )

  # Strategy-specific validations
  @test contains(runtests_content, "@testset")
  @test contains(runtests_content, "walkdir")
  @test contains(runtests_content, "test-.*\\.jl")
  @test !contains(runtests_content, "@run_package_tests")

  # Should have additional test file for auto-discovery
  @test has_test_file
end

@testitem "TestingStrategy defaults work correctly" tags = [:unit, :fast, :test_strategy] setup =
  [TestConstants, Common, StrategyTestHelpers] begin
  # Test each strategy level uses correct default
  strategy_levels = ["tiny", "light", "moderate", "robust"]

  for level in strategy_levels
    _with_tmp_dir() do dir
      # Use the predefined debug data (which contains TestingStrategy defaults)
      test_data = getfield(TestConstants.args.bestie, Symbol(level))

      # Generate package using default data
      BestieTemplate.generate(
        TestConstants.template_path,
        ".",
        test_data;
        defaults = true,
        quiet = true,
        vcs_ref = "HEAD",
      )

      # Read generated content to determine which strategy was used
      @test isfile("test/runtests.jl")
      runtests_content = read("test/runtests.jl", String)

      # Detect actual strategy from generated content
      actual_strategy = detect_strategy_from_content(runtests_content, "test")
      expected_strategy = expected_defaults[level]

      @test actual_strategy == expected_strategy
    end
  end

  # Test that explicit TestingStrategy overrides defaults
  _with_tmp_dir() do dir
    # Use tiny data but override with testitem_cli
    test_data = merge(TestConstants.args.bestie.tiny, Dict("TestingStrategy" => "testitem_cli"))

    BestieTemplate.generate(
      TestConstants.template_path,
      ".",
      test_data;
      defaults = true,
      quiet = true,
      vcs_ref = "HEAD",
    )

    runtests_content = read("test/runtests.jl", String)
    actual_strategy = detect_strategy_from_content(runtests_content, "test")

    # Should be testitem_cli despite tiny base (explicit override)
    @test actual_strategy == "testitem_cli"
  end
end
