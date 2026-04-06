@testsnippet AddFeatureHelpers begin
  using BestieTemplate
  using BestieTemplate.Debug.Data: Data
  using Test

  # Computed independently — no dependency on TestConstants
  _template_path = joinpath(@__DIR__, "..")

  function _generate_pkg(strategy::Symbol = :tiny; kwargs...)
    defaults = (; quiet = true, vcs_ref = "HEAD", defaults = true)
    BestieTemplate.generate(
      _template_path,
      ".",
      Data.strategies[strategy];
      merge(defaults, kwargs)...,
    )
  end

  """
  Call `BestieTemplate.add_feature` using the local template (avoids repeating kwargs in every test).
  """
  function _add_feature_local(feature::Symbol, data::Dict = Dict(); kwargs...)
    BestieTemplate.add_feature(
      feature,
      ".",
      data;
      template_source = :local,
      local_template_path = _template_path,
      kwargs...,
    )
  end

  """
  Happy-path pattern: generate a tiny package, assert `expected_files` are absent,
  call `add_feature(:feature)`, then assert they exist. Optionally check file contents and
  assert `unexpected_files` are absent.
  """
  function _test_happy_path(
    feature::Symbol,
    expected_files::Vector{String};
    unexpected_files::Vector{String} = String[],
    content_checks::Dict{String, Vector{String}} = Dict{String, Vector{String}}(),
  )
    _generate_pkg()
    for f in expected_files
      @test !isfile(f)
    end
    _add_feature_local(feature)
    for f in expected_files
      @test isfile(f)
    end
    for f in unexpected_files
      @test !isfile(f)
    end
    for (f, patterns) in content_checks
      content = read(f, String)
      for p in patterns
        @test contains(content, p)
      end
    end
  end

  """
  Without-answers pattern: generate a package, delete `.copier-answers.yml`, call
  `add_feature(:feature)`, then assert `expected_file` was written and `.copier-answers.yml`
  was NOT created.

  Use this for any feature with `requires_answers = false`.
  """
  function _test_works_without_answers(
    feature::Symbol,
    expected_file::String;
    generate_strategy::Symbol = :tiny,
    expected_content::Union{String, Nothing} = nothing,
  )
    _generate_pkg(generate_strategy)
    rm(".copier-answers.yml")
    _add_feature_local(feature)
    @test isfile(expected_file)
    @test !isfile(".copier-answers.yml")
    if !isnothing(expected_content)
      @test contains(read(expected_file, String), expected_content)
    end
  end

  """
  Bare-project pattern: create a minimal src/test tree, call `add_feature(:feature)`, then
  assert `expected_file` was written and `.copier-answers.yml` was NOT created.

  Use this for features with `required_fields = []` and `requires_answers = false`.
  """
  function _test_works_on_bare_project(feature::Symbol, expected_file::String)
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")
    _add_feature_local(feature)
    @test isfile(expected_file)
    @test !isfile(".copier-answers.yml")
  end

  """
  Error pattern: create a bare src dir (no guessable data, no answers), assert that
  `add_feature(:feature)` throws. Use this for features with `required_fields` that cannot be
  guessed, or with `requires_answers = true`.
  """
  function _test_errors_without_data(feature::Symbol)
    mkdir("src")
    @test_throws Exception _add_feature_local(feature)
  end

  """
  Preservation pattern: snapshot the current directory, call `add_feature(:feature)`, then
  assert that all files NOT in `changed_files` are unchanged and no unexpected new files
  were created. Tests the core `add_feature()` invariant: targeted regeneration leaves unrelated
  files untouched. One test covering this mechanism is sufficient — not needed per feature.
  """
  function _test_does_not_affect_other_files(
    feature::Symbol,
    changed_files::Vector{String},
    data::Dict = Dict(),
  )
    snapshot = Dict{String, Vector{UInt8}}()
    for (root, _, files) in walkdir(".")
      contains(root, ".git") && continue
      for file in files
        path = relpath(joinpath(root, file))
        snapshot[path] = read(path)
      end
    end

    _add_feature_local(feature, data)

    answers_path = ".copier-answers.yml"
    allowed = Set(push!(copy(changed_files), answers_path))
    for (path, old_content) in snapshot
      path in allowed && continue
      @test isfile(path)
      @test read(path) == old_content
    end
    after_files = Set(
      relpath(joinpath(root, file)) for (root, _, files) in walkdir(".") for
      file in files if !contains(root, ".git")
    )
    @test issubset(after_files, union(Set(keys(snapshot)), allowed))
  end

  """
  Data-override pattern: generate a tiny package, call `add_feature(:feature, custom_data)`,
  read `output_file`, assert it contains `expected` and optionally does NOT contain
  `unexpected`.

  Use this for features with `required_fields` — verifies the `data` argument takes
  priority over guessed and answers values (the escape hatch when auto-resolution fails).
  """
  function _test_explicit_data_override(
    feature::Symbol,
    custom_data::Dict,
    output_file::String,
    expected::String;
    unexpected::Union{String, Nothing} = nothing,
  )
    _generate_pkg()
    _add_feature_local(feature, custom_data)
    content = read(output_file, String)
    @test contains(content, expected)
    if !isnothing(unexpected)
      @test !contains(content, unexpected)
    end
  end
end

@testitem "add_feature(:testitem_cli) upgrades runtests.jl and preserves other files" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _generate_pkg()
    runtests_path = joinpath("test", "runtests.jl")
    @test !contains(read(runtests_path, String), "TAGS_DATA")
    # Verifies the preservation invariant: only the target file and .copier-answers.yml change
    _test_does_not_affect_other_files(:testitem_cli, [runtests_path])
    @test contains(read(runtests_path, String), "TAGS_DATA")
    @test contains(read(runtests_path, String), "parse_arguments")
    _validate_copier_answers(Dict("TestingStrategy" => "testitem_cli"))
  end
end

@testitem "add_feature(:testitem_cli) upgrades runtests.jl" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    runtests_path = joinpath("test", "runtests.jl")
    _generate_pkg()
    @test !contains(read(runtests_path, String), "TAGS_DATA")
    _add_feature_local(:testitem_cli)
    @test contains(read(runtests_path, String), "TAGS_DATA")
    @test contains(read(runtests_path, String), "parse_arguments")
  end
end

@testitem "add_feature(:testitem_cli) works without .copier-answers.yml when data is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  # Use light strategy so docs/make.jl exists and PackageOwner can be guessed
  _with_tmp_dir() do dir
    _test_works_without_answers(
      :testitem_cli,
      joinpath("test", "runtests.jl");
      generate_strategy = :light,
      expected_content = "TAGS_DATA",
    )
  end
end

@testitem "add_feature(:testitem_cli) data argument overrides guessed and answers values" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _generate_pkg()
    custom_owner = "CustomOwnerForTest"
    _add_feature_local(:testitem_cli, Dict("PackageOwner" => custom_owner))
    answers = _validate_copier_answers(Dict("TestingStrategy" => "testitem_cli"))
    @test answers["PackageOwner"] == custom_owner
  end
end

@testitem "add_feature(:testitem_cli) succeeds with explicit data on a non-Bestie project" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")
    _add_feature_local(
      :testitem_cli,
      Dict("PackageName" => "RescuePkg", "PackageOwner" => "rescuer", "Authors" => "Test Author"),
    )
    @test contains(read(joinpath("test", "runtests.jl"), String), "TAGS_DATA")
    @test !isfile(".copier-answers.yml")
  end
end

@testitem "add_feature(:testitem_cli) succeeds on a bare project without explicit data" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    mkdir("src")
    mkdir("test")
    write(joinpath("test", "runtests.jl"), "using Test")
    # testitem_cli has no required_fields, so placeholders suffice
    _add_feature_local(:testitem_cli)
    @test contains(read(joinpath("test", "runtests.jl"), String), "TAGS_DATA")
    @test !isfile(".copier-answers.yml")
  end
end

@testitem "add_feature(:pre_commit) generates pre-commit config and linter files" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_happy_path(
      :pre_commit,
      [
        ".pre-commit-config.yaml",
        ".JuliaFormatter.toml",
        ".editorconfig",
        ".yamlfmt.yml",
        ".yamllint.yml",
        ".markdownlint.json",
      ],
    )
  end
end

@testitem "add_feature(:pre_commit) works on a bare project" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_works_on_bare_project(:pre_commit, ".pre-commit-config.yaml")
  end
end

@testitem "add_feature(:pre_commit_without_config) generates only .pre-commit-config.yaml" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_happy_path(
      :pre_commit_without_config,
      [".pre-commit-config.yaml"];
      unexpected_files = [".JuliaFormatter.toml"],
    )
  end
end

@testitem "add_feature(:pre_commit_without_config) works on a bare project" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_works_on_bare_project(:pre_commit_without_config, ".pre-commit-config.yaml")
  end
end

@testitem "add_feature(:lint_action) generates Lint.yml workflow" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_happy_path(:lint_action, [joinpath(".github", "workflows", "Lint.yml")])
  end
end

@testitem "add_feature(:lint_action) errors without .copier-answers.yml when data is not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_errors_without_data(:lint_action)
  end
end

@testitem "add_feature(:dependabot) generates dependabot.yml" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_happy_path(
      :dependabot,
      [joinpath(".github", "dependabot.yml")];
      content_checks = Dict(joinpath(".github", "dependabot.yml") => ["FakePkg"]),
    )
  end
end

@testitem "add_feature(:dependabot) works without .copier-answers.yml when PackageName is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_works_without_answers(:dependabot, joinpath(".github", "dependabot.yml"))
  end
end

@testitem "add_feature(:dependabot) errors when PackageName is not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_errors_without_data(:dependabot)
  end
end

@testitem "add_feature(:dependabot) uses explicit PackageName over guessed value" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  # Tests the data merge priority: explicit data > guessed data > answers data.
  # Any feature with required_fields should have a test like this — it verifies
  # that callers can always satisfy required fields via the data argument, regardless
  # of package state. This is the escape hatch when guessing fails.
  _with_tmp_dir() do dir
    _test_explicit_data_override(
      :dependabot,
      Dict("PackageName" => "ExplicitPkgName"),
      joinpath(".github", "dependabot.yml"),
      "ExplicitPkgName";
      unexpected = "FakePkg",
    )
  end
end

@testitem "add_feature errors on unsupported feature symbol" tags = [:unit, :fast, :error_handling] setup =
  [Common, AddFeatureHelpers] begin
  _with_tmp_dir() do dir
    _test_errors_without_data(:nonexistent_feature)
  end
end
