@testitem "Compare copied project vs copier CLI baseline" setup = [Common] begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.robust) $(C.template_path) .`)
    _git_setup()
    _full_precommit()

    _with_tmp_dir() do dir_bestie
      BestieTemplate.Copier.copy(dir_bestie, C.args.bestie.robust; quiet = true, vcs_ref = "HEAD")
      _git_setup()
      _full_precommit()
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "Compare recopied project vs copier CLI baseline" setup = [Common] begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.robust) $(C.template_path) .`)
    _git_setup()
    _full_precommit()

    _with_tmp_dir() do dir_bestie
      run(
        `copier copy --vcs-ref HEAD --defaults --quiet $(C.args.copier.tiny) $(C.template_path) .`,
      )
      BestieTemplate.Copier.recopy(
        dir_bestie,
        C.args.bestie.robust;
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

@testitem "Compare updated project vs copier CLI baseline" setup = [Common] begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.robust) $(C.template_path) .`)
    _git_setup()
    _full_precommit()

    _with_tmp_dir() do dir_bestie
      run(`copier copy --defaults --quiet $(C.args.copier.tiny) $(C.template_path) .`)
      _git_setup()
      BestieTemplate.Copier.update(
        dir_bestie,
        C.args.bestie.robust;
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

@testitem "Compare BestieTemplate.generate vs copier CLI on HEAD" setup = [Common] begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.robust) $(C.template_path) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        C.template_path,
        dir_bestie,
        C.args.bestie.robust;
        quiet = true,
        vcs_ref = "HEAD",
      )
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testitem "Compare BestieTemplate.apply vs copier CLI copy on existing project" setup = [Common] begin
  function _fix_project_toml(dir)
    filename = joinpath(dir, "Project.toml")
    project_toml = replace(read(filename, String), r"uuid = .*" => "uuid = \"123\"")
    open(filename, "w") do io
      write(io, project_toml)
    end
    nothing
  end

  _with_tmp_dir() do dir_copier
    _basic_new_pkg("NewPkg")
    run(
      `copier copy --defaults --overwrite --quiet --vcs-ref HEAD $(C.args.copier.tiny) $(C.template_path) NewPkg`,
    )
    _fix_project_toml("NewPkg")

    _with_tmp_dir() do dir_bestie
      _basic_new_pkg("NewPkg")
      BestieTemplate.apply(
        C.template_path,
        joinpath(dir_bestie, "NewPkg"),
        C.args.bestie.tiny;
        defaults = true,
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      _fix_project_toml("NewPkg")
      _test_diff_dir(joinpath(dir_bestie, "NewPkg"), joinpath(dir_copier, "NewPkg"))
    end
  end
end

@testitem "Compare BestieTemplate.update vs copier CLI update" setup = [Common] begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --defaults --quiet $(C.args.copier.tiny) $(C.template_url) .`)
    _git_setup()
    run(`copier update --defaults --quiet $(C.args.copier.robust) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(dir_bestie, C.args.bestie.tiny; defaults = true, quiet = true)
      _git_setup()
      BestieTemplate.update(C.args.bestie.robust; defaults = true, quiet = true)

      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end
