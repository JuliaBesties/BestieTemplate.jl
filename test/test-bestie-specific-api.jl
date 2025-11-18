@testitem "Test automatic guessing of data - using random data" setup = [Common] begin
  src_data = copy(C.args.bestie.robust)
  guessable_answers = Set([
    "Authors",
    "JuliaMinVersion",
    "JuliaIndentation",
    "PackageName",
    "PackageOwner",
    "PackageUUID",
  ])

  for _ in 1:10
    for (key, value) in src_data
      src_data[key] = _random(Val(Symbol(key)), value)
    end

    _with_tmp_dir() do dir
      BestieTemplate.generate(C.template_path, ".", src_data; quiet = true, vcs_ref = "HEAD")

      # Test that guesses are correct
      data = BestieTemplate._read_data_from_existing_path(".")
      for (key, value) in data
        @test value == src_data[key]
      end
      # All keys were guessed
      @test Set(keys(data)) == guessable_answers

      # Test that keyword guess=false ignores the guessed data
      rm(".copier-answers.yml")
      _git_setup()
      BestieTemplate.apply(
        C.template_path,
        ".",
        C.args.bestie.robust;
        guess = false,
        overwrite = true,
        quiet = true,
        vcs_ref = "HEAD",
      )
      answers = YAML.load_file(".copier-answers.yml")
      data = BestieTemplate._read_data_from_existing_path(".")
      for (key, value) in data
        @test answers[key] == C.args.bestie.robust[key]
      end
    end
  end
end

@testitem "Test incomplete guesses - missing or incomplete Project.toml" setup = [Common] begin
  src_data = copy(C.args.bestie.robust)
  guessable_answers = Set([
    "Authors",
    "JuliaMinVersion",
    "JuliaIndentation",
    "PackageName",
    "PackageOwner",
    "PackageUUID",
  ])

  _with_tmp_dir() do dir
    BestieTemplate.generate(C.template_path, ".", src_data; quiet = true, vcs_ref = "HEAD")
    rm("Project.toml")
    @test_logs (:debug, "No Project.toml") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
    data = BestieTemplate._read_data_from_existing_path(".")
    for (key, value) in data
      @test value == src_data[key]
    end
    missing_keys = ["Authors", "JuliaMinVersion", "PackageName", "PackageUUID"]
    @test Set(keys(data)) == setdiff(guessable_answers, missing_keys)

    # Add empty Project.toml
    touch("Project.toml")
    @test_logs (:debug, "No key name in TOML") (:debug, "No key uuid in TOML") (
      :debug,
      "No authors information",
    ) (:debug, "No compat information") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
  end
end

@testitem "Test incomplete guesses - missing or incomplete docs/make.jl" setup = [Common] begin
  src_data = copy(C.args.bestie.robust)
  guessable_answers = Set([
    "Authors",
    "JuliaMinVersion",
    "JuliaIndentation",
    "PackageName",
    "PackageOwner",
    "PackageUUID",
  ])

  _with_tmp_dir() do dir
    BestieTemplate.generate(C.template_path, ".", src_data; quiet = true, vcs_ref = "HEAD")
    rm("docs/make.jl")
    @test_logs (:debug, "No file docs/make.jl") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
    data = BestieTemplate._read_data_from_existing_path(".")
    for (key, value) in data
      @test value == src_data[key]
    end
    missing_keys = ["PackageOwner"]
    @test Set(keys(data)) == setdiff(guessable_answers, missing_keys)

    # Add empty docs/make.jl
    touch("docs/make.jl")
    @test_logs (:debug, "No match for repo regex") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
  end
end

@testitem "Test incomplete guesses - missing or incomplete .JuliaFormatter.toml" setup = [Common] begin
  src_data = copy(C.args.bestie.robust)
  guessable_answers = Set([
    "Authors",
    "JuliaMinVersion",
    "JuliaIndentation",
    "PackageName",
    "PackageOwner",
    "PackageUUID",
  ])

  _with_tmp_dir() do dir
    BestieTemplate.generate(C.template_path, ".", src_data; quiet = true, vcs_ref = "HEAD")
    rm(".JuliaFormatter.toml")
    @test_logs (:debug, "No file .JuliaFormatter.toml") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
    data = BestieTemplate._read_data_from_existing_path(".")
    for (key, value) in data
      @test value == src_data[key]
    end
    missing_keys = ["JuliaIndentation"]
    @test Set(keys(data)) == setdiff(guessable_answers, missing_keys)

    # Add empty .JuliaFormatter.toml
    touch(".JuliaFormatter.toml")
    @test_logs (:debug, "No indent found in .JuliaFormatter.toml") min_level = Logging.Debug BestieTemplate._read_data_from_existing_path(
      ".",
    )
  end
end

@testitem "Test applying the template on an existing project" setup = [Common] begin
  _with_tmp_dir() do dir_existing
    _basic_new_pkg("NewPkg")
    BestieTemplate.apply(
      C.template_path,
      "NewPkg/",
      Dict("Authors" => "T. Esther", "PackageOwner" => "test");
      defaults = true,
      overwrite = true,
      quiet = true,
      vcs_ref = "HEAD",
    )
    answers = YAML.load_file("NewPkg/.copier-answers.yml")
    @test answers["PackageName"] == "NewPkg"
    @test answers["Authors"] == "T. Esther"
    @test answers["PackageOwner"] == "test"
  end
end

@testitem "Test automatic guessing the package name from the path" setup = [Common] begin
  _with_tmp_dir() do dir_path_is_dir
    data = Dict(key => value for (key, value) in C.args.bestie.robust if key != "PackageName")
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

@testitem "Test that bad PackageName gets flagged" setup = [Common] begin
  _with_tmp_dir() do dir
    for name in ["Bad.jl", "0Bad", "bad"]
      data = copy(C.args.bestie.robust)
      data["PackageName"] = name
      @test_logs (
        :error,
        "Error generating project: Validation error for question 'PackageName': Must start with a capital letter, and use letters or numbers only",
      ) match_mode = :any BestieTemplate.generate(
        C.template_path,
        ".",
        data,
        quiet = true,
        vcs_ref = "HEAD",
      )
    end
  end
end

@testitem "Test input validation of apply - dst_path does not exist" setup = [Common] begin
  _with_tmp_dir() do dir
    @test_throws Exception BestieTemplate.apply("some_folder1", quiet = true)
  end
end

@testitem "Test input validation of apply - dst_path exists but no .git" setup = [Common] begin
  _with_tmp_dir() do dir
    mkdir("some_folder2")
    @test_throws Exception BestieTemplate.apply("some_folder2", quiet = true)
  end
end

@testitem "Test quick pkg creation" setup = [Common] begin
  _with_tmp_dir() do dir
    BestieTemplate.new_pkg_quick("NewPkg.jl", "JuliaBesties", "JuliaBesties maintainers", :tiny)

    filename = joinpath("NewPkg.jl", "Project.toml")
    @test isfile(filename)

    toml = TOML.parsefile(filename)
    @test toml["authors"] == ["JuliaBesties maintainers"]
  end
end

# Don't run for branch main or tags
if get(ENV, "BESTIE_SKIP_UPDATE_TEST", "no") != "yes" &&
   chomp(read(`git branch --show-current`, String)) != "main" &&
   get(ENV, "GITHUB_REF_TYPE", "nothing") != "tag"
  @testitem "Test updating from main to HEAD vs generate in HEAD" setup = [Common] begin
    _with_tmp_dir() do dir
      common_args = (defaults = true, quiet = true)

      mkdir("gen_then_up")
      cd("gen_then_up") do
        # Generate the release version
        BestieTemplate.generate(
          C.template_path,
          ".",
          C.args.bestie.robust;
          vcs_ref = "main",
          common_args...,
        )
        _git_setup()
        _full_precommit()
        # Update using the HEAD version
        BestieTemplate.update(".", C.args.bestie.robust; vcs_ref = "HEAD", common_args...)
        _full_precommit()
      end

      mkdir("gen_direct")
      cd("gen_direct") do
        # Generate directly in the HEAD version
        BestieTemplate.generate(
          C.template_path,
          ".",
          C.args.bestie.robust;
          vcs_ref = "HEAD",
          common_args...,
        )
        _git_setup()
        _full_precommit()
      end

      _test_diff_dir("gen_then_up", "gen_direct")
    end
  end
end
