@testset "Automatic guessing of data" begin
  src_data = copy(C.args.bestie.ask)
  @testset "Using random data" for _ in 1:10
    for (key, value) in src_data
      src_data[key] = _random(Val(Symbol(key)), value)
    end

    _with_tmp_dir() do dir
      BestieTemplate.generate(C.template_path, ".", src_data; quiet = true, vcs_ref = "HEAD")

      @testset "Test that guesses are correct" begin
        data = BestieTemplate._read_data_from_existing_path(".")
        @testset for (key, value) in data
          @test value == src_data[key]
        end
        @testset "All keys were guessed" begin
          @test Set(keys(data)) == Set(["AuthorEmail", "AuthorName", "PackageName", "PackageUUID"])
        end
      end

      @testset "Test that keyword guess=false ignores the guessed data" begin
        rm(".copier-answers.yml")
        _git_setup()
        BestieTemplate.apply(
          C.template_path,
          ".",
          C.args.bestie.ask;
          guess = false,
          overwrite = true,
          quiet = true,
          vcs_ref = "HEAD",
        )
        answers = YAML.load_file(".copier-answers.yml")
        data = BestieTemplate._read_data_from_existing_path(".")
        for (key, value) in data
          @test answers[key] == C.args.bestie.ask[key]
        end
      end
    end
  end
end

@testset "Test applying the template on an existing project" begin
  _with_tmp_dir() do dir_existing
    _basic_new_pkg("NewPkg")
    BestieTemplate.apply(
      C.template_path,
      "NewPkg/",
      Dict("AuthorName" => "T. Esther", "PackageOwner" => "test");
      defaults = true,
      overwrite = true,
      quiet = true,
      vcs_ref = "HEAD",
    )
    answers = YAML.load_file("NewPkg/.copier-answers.yml")
    @test answers["PackageName"] == "NewPkg"
    @test answers["AuthorName"] == "T. Esther"
    @test answers["PackageOwner"] == "test"
  end

  @testset "Test automatic guessing the package name from the path" begin
    _with_tmp_dir() do dir_path_is_dir
      data = Dict(key => value for (key, value) in C.args.bestie.ask if key != "PackageName")
      mkdir("some_folder")
      BestieTemplate.generate(
        C.template_path,
        "some_folder/SomePackage1.jl",
        data;
        quiet = true,
        vcs_ref = "HEAD",
      )
      answers = YAML.load_file("some_folder/SomePackage1.jl/.copier-answers.yml")
      @test answers["PackageName"] == "SomePackage1"
      BestieTemplate.generate(
        C.template_path,
        "some_folder/SomePackage2.jl",
        merge(data, Dict("PackageName" => "OtherName"));
        quiet = true,
        vcs_ref = "HEAD",
      )
      answers = YAML.load_file("some_folder/SomePackage2.jl/.copier-answers.yml")
      @test answers["PackageName"] == "OtherName"
    end
  end

  @testset "Test that bad PackageName gets flagged" begin
    _with_tmp_dir() do dir
      for name in ["Bad.jl", "0Bad", "bad"]
        data = copy(C.args.bestie.ask)
        data["PackageName"] = name
        @test_throws PythonCall.Core.PyException BestieTemplate.generate(
          C.template_path,
          ".",
          data,
          quiet = true,
          vcs_ref = "HEAD",
        )
      end
    end
  end

  @testset "Test input validation of apply" begin
    _with_tmp_dir() do dir
      @testset "It fails if the dst_path does not exist" begin
        @test_throws Exception BestieTemplate.apply("some_folder1", quiet = true)
      end

      @testset "It fails if the dst_path exists but does not contains .git" begin
        mkdir("some_folder2")
        @test_throws Exception BestieTemplate.apply("some_folder2", quiet = true)
      end
    end
  end
end
