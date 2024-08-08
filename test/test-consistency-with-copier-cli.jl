@testset "Testing copy, recopy and rebase" begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.ask) $(C.template_path) .`)

    @testset "Compare copied project vs copier CLI baseline" begin
      _with_tmp_dir() do dir_bestie
        BestieTemplate.Copier.copy(dir_bestie, C.args.bestie.ask; quiet = true, vcs_ref = "HEAD")
        _test_diff_dir(dir_bestie, dir_copier)
      end
    end

    @testset "Compare recopied project vs copier CLI baseline" begin
      _with_tmp_dir() do dir_bestie
        run(
          `copier copy --vcs-ref HEAD --defaults --quiet $(C.args.copier.min) $(C.template_path) .`,
        )
        BestieTemplate.Copier.recopy(
          dir_bestie,
          C.args.bestie.ask;
          quiet = true,
          overwrite = true,
          vcs_ref = "HEAD",
        )
        _test_diff_dir(dir_bestie, dir_copier)
      end
    end

    @testset "Compare updated project vs copier CLI baseline" begin
      _with_tmp_dir() do dir_bestie
        run(`copier copy --defaults --quiet $(C.args.copier.min) $(C.template_path) .`)
        _git_setup()
        BestieTemplate.Copier.update(
          dir_bestie,
          C.args.bestie.ask;
          overwrite = true,
          quiet = true,
          vcs_ref = "HEAD",
        )
        _test_diff_dir(dir_bestie, dir_copier)
      end
    end
  end
end

@testset "Compare BestieTemplate.generate vs copier CLI on URL/main" begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref main --quiet $(C.args.copier.ask) $(C.template_url) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(dir_bestie, C.args.bestie.ask; quiet = true, vcs_ref = "main")
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testset "Compare BestieTemplate.generate vs copier CLI on HEAD" begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.ask) $(C.template_path) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(
        C.template_path,
        dir_bestie,
        C.args.bestie.ask;
        quiet = true,
        vcs_ref = "HEAD",
      )
      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end

@testset "Compare BestieTemplate.apply vs copier CLI copy on existing project" begin
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
      `copier copy --overwrite --quiet --vcs-ref HEAD $(C.args.copier.min) $(C.template_path) NewPkg`,
    )
    _fix_project_toml("NewPkg")

    _with_tmp_dir() do dir_bestie
      _basic_new_pkg("NewPkg")
      BestieTemplate.apply(
        C.template_path,
        joinpath(dir_bestie, "NewPkg"),
        C.args.bestie.min;
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      _fix_project_toml("NewPkg")
      _test_diff_dir(joinpath(dir_bestie, "NewPkg"), joinpath(dir_copier, "NewPkg"))
    end
  end
end

@testset "Compare BestieTemplate.update vs copier CLI update" begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --defaults --quiet $(C.args.copier.min) $(C.template_url) .`)
    _git_setup()
    run(`copier update --defaults --quiet $(C.args.copier.ask) .`)

    _with_tmp_dir() do dir_bestie
      BestieTemplate.generate(dir_bestie, C.args.bestie.min; defaults = true, quiet = true)
      _git_setup()
      BestieTemplate.update(C.args.bestie.ask; defaults = true, quiet = true)

      _test_diff_dir(dir_bestie, dir_copier)
    end
  end
end
