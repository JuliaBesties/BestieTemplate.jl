@testitem "Using new_pkg_quick with :local" tags = [:unit, :fast] setup = [Common] begin
  using Logging

  test_pkg_name = "NewPkg.jl"
  test_owner = "JuliaBesties"
  test_authors = "JuliaBesties maintainers"

  # Default behaviour is to have no warning
  _with_tmp_dir() do dir
    @test_logs min_level = Logging.Warn BestieTemplate.new_pkg_quick(
      test_pkg_name,
      test_owner,
      test_authors,
      :tiny,
    )
  end

  # If using `:local` but the `pkgdir` has a `.git` folder, nothing happens
  _with_tmp_dir() do dir
    @test_logs min_level = Logging.Warn BestieTemplate.new_pkg_quick(
      test_pkg_name,
      test_owner,
      test_authors,
      :tiny,
      template_source = :local,
    )
  end

  # If using `:local` and the `pkgdir` has no `.git` folder, then warns
  _with_tmp_dir() do dir
    # Creating a copy of BestieTemplate without the .git folder:
    run(`git clone $(pkgdir(BestieTemplate)) BestieTemplateCopy`)
    run(`rm -rf ./BestieTemplateCopy/.git`)

    @test_logs (
      :warn,
      "Local path BestieTemplateCopy is not tracked with .git, updates won't be possible without manual intervention",
    ) BestieTemplate.new_pkg_quick(
      test_pkg_name,
      test_owner,
      test_authors,
      :tiny,
      local_template_path = "BestieTemplateCopy",
      template_source = :local,
    )
  end
end
