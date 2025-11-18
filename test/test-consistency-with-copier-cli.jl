@testsnippet CliComparisonHelpers begin
  # Helper to create copier CLI baseline with git setup and precommit
  function create_copier_baseline(copier_args, template_path)
    run(`copier copy --vcs-ref HEAD --quiet $copier_args $template_path .`)
    _git_setup()
    _full_precommit()
  end

  # Helper to fix Project.toml UUID for consistent comparison
  function fix_project_toml_uuid(dir, uuid = "123")
    filename = joinpath(dir, "Project.toml")
    project_toml = replace(read(filename, String), r"uuid = .*" => "uuid = \"$uuid\"")
    open(filename, "w") do io
      write(io, project_toml)
    end
  end

  # Helper to handle the copier issue #1867 workaround
  function apply_copier_workaround(dir)
    # Due to https://github.com/copier-org/copier/issues/1867 we need to remove test/Project.toml
    # before replacing it by something else.
    test_project_path = joinpath(dir, "test", "Project.toml")
    if isfile(test_project_path)
      rm(test_project_path)
    end
  end
end

@testitem "Copier.copy produces same result as copier CLI copy" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    create_copier_baseline(TestConstants.args.copier.robust, TestConstants.template_path)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.Copier.copy(
        dir_bestie,
        TestConstants.args.bestie.robust;
        quiet = true,
        vcs_ref = "HEAD",
      )
      _git_setup()
      _full_precommit()
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "Copier.recopy produces same result as copier CLI baseline" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    create_copier_baseline(TestConstants.args.copier.robust, TestConstants.template_path)

    _with_tmp_dir() do dir_bestie
      run(
        `copier copy --vcs-ref HEAD --defaults --quiet $(TestConstants.args.copier.tiny) $(TestConstants.template_path) .`,
      )
      apply_copier_workaround(dir_bestie)

      BestieTemplate.Copier.recopy(
        dir_bestie,
        TestConstants.args.bestie.robust;
        quiet = true,
        overwrite = true,
        vcs_ref = "HEAD",
      )
      _git_setup()
      _full_precommit()
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "Copier.update produces same result as copier CLI update" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    create_copier_baseline(TestConstants.args.copier.robust, TestConstants.template_path)

    _with_tmp_dir() do dir_bestie
      run(
        `copier copy --defaults --quiet $(TestConstants.args.copier.tiny) $(TestConstants.template_path) .`,
      )
      apply_copier_workaround(dir_bestie)
      _git_setup()
      BestieTemplate.Copier.update(
        dir_bestie,
        TestConstants.args.bestie.robust;
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      _git_setup()
      _full_precommit()
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "BestieTemplate.generate produces same result as copier CLI" tags =
  [:integration, :slow, :copier_compatibility, :python_integration] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    run(
      `copier copy --vcs-ref HEAD --quiet $(TestConstants.args.copier.robust) $(TestConstants.template_path) .`,
    )

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        TestConstants.template_path,
        dir_bestie,
        TestConstants.args.bestie.robust;
        quiet = true,
        vcs_ref = "HEAD",
      )
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "BestieTemplate.apply produces same result as copier CLI on existing project" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    _basic_new_pkg("NewPkg")
    run(
      `copier copy --defaults --overwrite --quiet --vcs-ref HEAD $(TestConstants.args.copier.tiny) $(TestConstants.template_path) NewPkg`,
    )
    fix_project_toml_uuid("NewPkg")

    _with_tmp_dir() do dir_bestie
      _basic_new_pkg("NewPkg")
      BestieTemplate.apply(
        TestConstants.template_path,
        joinpath(dir_bestie, "NewPkg"),
        TestConstants.args.bestie.tiny;
        defaults = true,
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      fix_project_toml_uuid("NewPkg")
      _test_diff_dir(joinpath(dir_bestie, "NewPkg"), joinpath(dir_copier, "NewPkg"))
    end
  end
end

@testitem "BestieTemplate.update produces same result as copier CLI update" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  _with_tmp_dir() do dir_copier
    run(
      `copier copy --defaults --quiet $(TestConstants.args.copier.tiny) $(TestConstants.template_url) .`,
    )
    _git_setup()
    run(`copier update --defaults --quiet $(TestConstants.args.copier.robust) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        dir_bestie,
        TestConstants.args.bestie.tiny;
        defaults = true,
        quiet = true,
      )
      _git_setup()
      BestieTemplate.update(TestConstants.args.bestie.robust; defaults = true, quiet = true)

      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end
