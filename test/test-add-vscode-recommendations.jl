@testitem ".vscode/extensions.json is created when AddVSCodeRecommendations is enabled" tags =
  [:unit, :fast, :file_io] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.robust)

    extensions_path = joinpath(".vscode", "extensions.json")
    @test isfile(extensions_path)
    content = read(extensions_path, String)
    @test contains(content, "julialang.language-julia")
  end
end

@testitem ".vscode/extensions.json is absent when AddVSCodeRecommendations is disabled" tags =
  [:unit, :fast, :file_io] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir
    _generate_test_package(".", TestConstants.args.bestie.tiny)

    @test !isfile(joinpath(".vscode", "extensions.json"))
    @test !isdir(".vscode")
  end
end
