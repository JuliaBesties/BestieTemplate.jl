@testsnippet CliComparisonHelpers begin
  # Function to get common CLI args (accessed from test items with TestConstants)
  function get_common_cli_args()
    return (
      template_path = TestConstants.template_path,
      template_url = TestConstants.template_url,
      robust_bestie = TestConstants.args.bestie.robust,
      robust_copier = TestConstants.args.copier.robust,
      tiny_bestie = TestConstants.args.bestie.tiny,
      tiny_copier = TestConstants.args.copier.tiny,
      quiet = true,
      vcs_ref = "HEAD",
    )
  end

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
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    create_copier_baseline(common_cli_args.robust_copier, common_cli_args.template_path)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.Copier.copy(
        dir_bestie,
        common_cli_args.robust_bestie;
        quiet = common_cli_args.quiet,
        vcs_ref = common_cli_args.vcs_ref,
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
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    create_copier_baseline(common_cli_args.robust_copier, common_cli_args.template_path)

    _with_tmp_dir() do dir_bestie
      run(
        `copier copy --vcs-ref HEAD --defaults --quiet $(common_cli_args.tiny_copier) $(common_cli_args.template_path) .`,
      )
      apply_copier_workaround(dir_bestie)

      BestieTemplate.Copier.recopy(
        dir_bestie,
        common_cli_args.robust_bestie;
        quiet = common_cli_args.quiet,
        overwrite = true,
        vcs_ref = common_cli_args.vcs_ref,
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
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    create_copier_baseline(common_cli_args.robust_copier, common_cli_args.template_path)

    _with_tmp_dir() do dir_bestie
      run(
        `copier copy --defaults --quiet $(common_cli_args.tiny_copier) $(common_cli_args.template_path) .`,
      )
      apply_copier_workaround(dir_bestie)
      _git_setup()
      BestieTemplate.Copier.update(
        dir_bestie,
        common_cli_args.robust_bestie;
        overwrite = true,
        quiet = common_cli_args.quiet,
        vcs_ref = common_cli_args.vcs_ref,
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
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    run(
      `copier copy --vcs-ref HEAD --quiet $(common_cli_args.robust_copier) $(common_cli_args.template_path) .`,
    )

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        common_cli_args.template_path,
        dir_bestie,
        common_cli_args.robust_bestie;
        quiet = common_cli_args.quiet,
        vcs_ref = common_cli_args.vcs_ref,
      )
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "BestieTemplate.apply produces same result as copier CLI on existing project" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    _basic_new_pkg("NewPkg")
    run(
      `copier copy --defaults --overwrite --quiet --vcs-ref HEAD $(common_cli_args.tiny_copier) $(common_cli_args.template_path) NewPkg`,
    )
    fix_project_toml_uuid("NewPkg")

    _with_tmp_dir() do dir_bestie
      _basic_new_pkg("NewPkg")
      BestieTemplate.apply(
        common_cli_args.template_path,
        joinpath(dir_bestie, "NewPkg"),
        common_cli_args.tiny_bestie;
        defaults = true,
        overwrite = true,
        quiet = common_cli_args.quiet,
        vcs_ref = common_cli_args.vcs_ref,
      )
      fix_project_toml_uuid("NewPkg")
      _test_diff_dir(joinpath(dir_bestie, "NewPkg"), joinpath(dir_copier, "NewPkg"))
    end
  end
end

@testitem "BestieTemplate.update produces same result as copier CLI update" tags =
  [:integration, :slow, :copier_compatibility, :python_integration, :git_operations] setup =
  [TestConstants, Common, CliComparisonHelpers] begin
  common_cli_args = get_common_cli_args()
  _with_tmp_dir() do dir_copier
    run(
      `copier copy --defaults --quiet $(common_cli_args.tiny_copier) $(common_cli_args.template_url) .`,
    )
    _git_setup()
    run(`copier update --defaults --quiet $(common_cli_args.robust_copier) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        dir_bestie,
        common_cli_args.tiny_bestie;
        defaults = true,
        quiet = true,
      )
      _git_setup()
      BestieTemplate.update(common_cli_args.robust_bestie; defaults = true, quiet = true)

      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end
