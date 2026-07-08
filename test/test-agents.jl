@testitem "AGENTS.md is created when AddAgentsMd is enabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.robust)

    @test isfile("AGENTS.md")
    content = read("AGENTS.md", String)
    @test contains(content, TestConstants.args.bestie.robust["PackageName"])
    @test contains(content, "Pkg.test()")
    # robust uses TestingStrategy = testitem_basic, so the julia-mcp section is included
    @test contains(content, "@run_package_tests")
    @test !contains(content, "test/runtests.jl") # only for testitem_cli
  end
end

@testitem "AGENTS.md is absent when AddAgentsMd is disabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.tiny)

    @test !isfile("AGENTS.md")
  end
end
