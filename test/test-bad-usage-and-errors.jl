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

@testitem "Copier temp clone cleanup failure is ignored" tags =
  [:unit, :fast, :error_handling, :python_integration] setup = [Common] begin
  Copier = BestieTemplate.Copier

  # Reproduces the OSError raised when Copier's cleanup of its temporary VCS
  # clone loses the rmtree race (the copy itself has already succeeded).
  function _cleanup_race_exception(filename)
    try
      PythonCall.pyexec("raise OSError(39, 'Directory not empty', '$filename')", @__MODULE__)
      error("unreachable")
    catch ex
      return ex
    end
  end

  ex = _cleanup_race_exception("/tmp/copier._vcs.clone.test123/.git/objects")
  @test Copier._copier_tempdir_from_exception(ex) == "/tmp/copier._vcs.clone.test123"

  # OSError outside a copier temp clone is not swallowed
  ex_other = _cleanup_race_exception("/tmp/some-other-dir/.git/objects")
  @test isnothing(Copier._copier_tempdir_from_exception(ex_other))
  @test_throws PythonCall.PyException Copier._ignore_cleanup_race(() -> throw(ex_other))

  # Non-Python exceptions are not swallowed
  @test_throws ErrorException Copier._ignore_cleanup_race(() -> error("boom"))

  # The race is swallowed and the leftover temporary clone is removed
  mktempdir() do dir
    clone_dir = joinpath(dir, "copier._vcs.clone.test456")
    mkpath(joinpath(clone_dir, ".git", "objects"))
    ex_race = _cleanup_race_exception(joinpath(clone_dir, ".git", "objects"))
    @test isnothing(Copier._ignore_cleanup_race(() -> throw(ex_race)))
    @test !isdir(clone_dir)
  end

  # Successful calls pass their value through
  @test Copier._ignore_cleanup_race(() -> 42) == 42
end
