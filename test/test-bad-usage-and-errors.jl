@testitem "BestieTemplate.apply warns for existing copier projects" tags =
  [:unit, :fast, :error_handling, :python_integration] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir_copier
    # Set up existing copier project
    run(
      `copier copy --vcs-ref HEAD --quiet $(TestConstants.args.copier.robust) $(TestConstants.template_path) .`,
    )
    _git_setup()

    # Test that apply warns when used on existing copier project
    @test_logs (:warn,) BestieTemplate.apply("."; quiet = true)
    @test_logs (:warn,) BestieTemplate.apply(dir_copier; quiet = true)
  end
end

@testitem "Generate fails for non-empty destination directory" tags =
  [:unit, :fast, :error_handling, :validation] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir
    # Create non-empty directory
    _create_non_empty_dir("some_folder1")

    @test_throws Exception BestieTemplate.generate("some_folder1")
  end
end

@testitem "Generate succeeds when destination is current directory" tags =
  [:unit, :fast, :validation, :file_io] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir
    mkdir("some_folder2")
    cd("some_folder2") do
      # Should not throw
      _generate_test_package(".", TestConstants.args.bestie.robust)
    end
  end
end

@testitem "Generate succeeds for empty destination directory" tags =
  [:unit, :fast, :validation, :file_io] setup = [TestConstants, Common] begin
  _with_tmp_dir() do dir
    mkdir("some_folder3")
    # Should not throw
    _generate_test_package("some_folder3", TestConstants.args.bestie.robust)
  end
end
