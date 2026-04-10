@testitem "CHANGELOG.md is created when AddChangelog is enabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.robust)

    @test isfile("CHANGELOG.md")
    content = read("CHANGELOG.md", String)
    @test contains(content, "Keep a Changelog")
    @test contains(content, "Semantic Versioning")
    @test contains(content, "## [Unreleased]")
    @test contains(content, TestConstants.args.bestie.robust["PackageOwner"])
    @test contains(content, TestConstants.args.bestie.robust["PackageName"])
  end
end

@testitem "CHANGELOG.md is absent when AddChangelog is disabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.tiny)

    @test !isfile("CHANGELOG.md")
  end
end

@testitem "Developer docs include changelog section when enabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.robust)

    dev_docs = read("docs/src/91-developer.md", String)
    @test contains(dev_docs, "Update the `CHANGELOG.md`")
  end
end

@testitem "Developer docs exclude changelog section when disabled" tags = [:unit, :fast, :file_io] setup =
  [TestConstants, Common] begin
  _with_tmp_dir() do dir
    data = merge(TestConstants.args.bestie.robust, Dict("AddChangelog" => false))
    _generate_test_package(".", data)

    dev_docs = read("docs/src/91-developer.md", String)
    @test !contains(dev_docs, "Update the `CHANGELOG.md`")
  end
end
