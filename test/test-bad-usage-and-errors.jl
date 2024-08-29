
@testset "Test that BestieTemplate.generate warns and exits for existing copy" begin
  _with_tmp_dir() do dir_copier
    run(`copier copy --vcs-ref HEAD --quiet $(C.args.copier.ask) $(C.template_url) .`)
    _git_setup()

    @test_logs (:warn,) BestieTemplate.apply("."; quiet = true)
    @test_logs (:warn,) BestieTemplate.apply(dir_copier; quiet = true)
  end
end

@testset "Test that generate fails for existing non-empty paths" begin
  _with_tmp_dir() do dir
    @testset "It fails if the dst_path exists and is non-empty" begin
      mkdir("some_folder1")
      open(joinpath("some_folder1", "README.md"), "w") do io
        println(io, "Hi")
      end
      @test_throws Exception BestieTemplate.generate("some_folder1")
    end

    @testset "It works if the dst_path is ." begin
      mkdir("some_folder2")
      cd("some_folder2") do
        @show readdir(".")
        # Should not throw
        BestieTemplate.generate(
          C.template_path,
          ".",
          C.args.bestie.ask;
          quiet = true,
          vcs_ref = "HEAD",
        )
      end
    end

    @testset "It works if the dst_path exists but is empty" begin
      mkdir("some_folder3")
      # Should not throw
      BestieTemplate.generate(
        C.template_path,
        "some_folder3",
        C.args.bestie.ask;
        quiet = true,
        vcs_ref = "HEAD",
      )
    end
  end
end
