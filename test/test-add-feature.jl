@testsnippet AddFeatureHelpers begin
  using BestieTemplate
  using BestieTemplate.Debug.Data: Data
  using Test

  # Computed independently, no dependency on TestConstants
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
  Uses `use_latest = true` so tests run against the working tree, not the latest tagged release.
  """
  function _add_feature_local(feature::Symbol, data::Dict = Dict(); kwargs...)
    BestieTemplate.add_feature(
      feature,
      ".",
      data;
      template_source = :local,
      local_template_path = _template_path,
      use_latest = true,
      kwargs...,
    )
  end

  """
  Happy-path pattern: generate a tiny package, call `add_feature(:feature)`, then assert
  `expected_files` exist. Optionally check file contents and assert `unexpected_files` are absent.
  """
  function _test_happy_path(
    feature::Symbol,
    expected_files::Vector{String};
    unexpected_files::Vector{String} = String[],
    content_checks::Dict{String, Vector{String}} = Dict{String, Vector{String}}(),
  )
    _with_tmp_dir() do _
      _generate_pkg()
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
  end

  """
  Without-answers pattern: generate a package, delete `.copier-answers.yml`, call
  `add_feature(:feature)`, then assert `expected_file` was written and `.copier-answers.yml`
  was NOT recreated. Use when the feature can resolve required data by guessing from project files.

  Use this for features with `requires_answers = false` and non-empty `required_fields`.
  """
  function _test_works_without_answers_by_guessing(
    feature::Symbol,
    expected_file::String;
    generate_strategy::Symbol = :tiny,
    expected_content::Union{String, Nothing} = nothing,
  )
    _with_tmp_dir() do _
      _generate_pkg(generate_strategy)
      rm(".copier-answers.yml")
      _add_feature_local(feature)
      @test isfile(expected_file)
      @test !isfile(".copier-answers.yml")
      if !isnothing(expected_content)
        @test contains(read(expected_file, String), expected_content)
      end
    end
  end

  """
  Empty-folder pattern: call `add_feature(:feature)` in an empty directory, then assert
  `expected_file` was written and `.copier-answers.yml` was NOT created.

  Use this for features with `required_fields = []` and `requires_answers = false`.
  """
  function _test_works_on_empty_folder(
    feature::Symbol,
    expected_file::String;
    data::Dict = Dict(),
    expected_content::Union{String, Nothing} = nothing,
  )
    _with_tmp_dir() do _
      _add_feature_local(feature, data)
      @test isfile(expected_file)
      @test !isfile(".copier-answers.yml")
      if !isnothing(expected_content)
        @test contains(read(expected_file, String), expected_content)
      end
    end
  end

  """
  Error pattern: create a bare src dir (no guessable data, no answers), assert that
  `add_feature(:feature)` throws. Use this for features with `required_fields` that cannot be
  guessed, or with `requires_answers = true`.
  """
  function _test_errors_without_data(feature::Symbol)
    _with_tmp_dir() do _
      mkdir("src")
      @test_throws Exception _add_feature_local(feature)
    end
  end

  """
  Preservation pattern: snapshot the current directory, call `add_feature(:feature)`, then
  assert that all files NOT in `changed_files` are unchanged and no unexpected new files
  were created. Tests the core `add_feature()` invariant: targeted regeneration leaves unrelated
  files untouched. One test covering this mechanism is sufficient; not needed per feature.
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

  Use this for features with `required_fields`. Verifies the `data` argument takes
  priority over guessed and answers values (the escape hatch when auto-resolution fails).
  """
  function _test_explicit_data_override(
    feature::Symbol,
    custom_data::Dict,
    output_file::String,
    expected::String;
    unexpected::Union{String, Nothing} = nothing,
  )
    _with_tmp_dir() do _
      _generate_pkg()
      _add_feature_local(feature, custom_data)
      content = read(output_file, String)
      @test contains(content, expected)
      if !isnothing(unexpected)
        @test !contains(content, unexpected)
      end
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
  runtests_path = joinpath("test", "runtests.jl")
  _test_happy_path(
    :testitem_cli,
    [runtests_path];
    content_checks = Dict(runtests_path => ["TAGS_DATA", "parse_arguments"]),
  )
end

@testitem "add_feature(:testitem_cli) works without .copier-answers.yml when data is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  # Use light strategy so docs/make.jl exists and PackageOwner can be guessed
  _test_works_without_answers_by_guessing(
    :testitem_cli,
    joinpath("test", "runtests.jl");
    generate_strategy = :light,
    expected_content = "TAGS_DATA",
  )
end

@testitem "add_feature(:testitem_cli) succeeds on an empty folder" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_works_on_empty_folder(
    :testitem_cli,
    joinpath("test", "runtests.jl");
    expected_content = "TAGS_DATA",
  )
end

@testitem "add_feature(:pre_commit) generates pre-commit config and linter files" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
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

@testitem "add_feature(:pre_commit) works on an empty folder" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_works_on_empty_folder(:pre_commit, ".pre-commit-config.yaml")
end

@testitem "add_feature(:pre_commit_without_config) generates only .pre-commit-config.yaml" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_happy_path(
    :pre_commit_without_config,
    [".pre-commit-config.yaml"];
    unexpected_files = [".JuliaFormatter.toml"],
  )
end

@testitem "add_feature(:pre_commit_without_config) works on an empty folder" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_works_on_empty_folder(:pre_commit_without_config, ".pre-commit-config.yaml")
end

@testitem "add_feature(:lint_action) generates Lint.yml workflow" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_happy_path(:lint_action, [joinpath(".github", "workflows", "Lint.yml")])
end

@testitem "add_feature(:lint_action) errors without .copier-answers.yml when data is not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _test_errors_without_data(:lint_action)
end

@testitem "add_feature(:dependabot) generates dependabot.yml" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_happy_path(
    :dependabot,
    [joinpath(".github", "dependabot.yml")];
    content_checks = Dict(joinpath(".github", "dependabot.yml") => ["FakePkg"]),
  )
end

@testitem "add_feature(:dependabot) works without .copier-answers.yml when PackageName is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_works_without_answers_by_guessing(:dependabot, joinpath(".github", "dependabot.yml"))
end

@testitem "add_feature(:dependabot) errors when PackageName is not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _test_errors_without_data(:dependabot)
end

@testitem "add_feature(:dependabot) uses explicit PackageName over guessed value" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  # Tests the data merge priority: explicit data > guessed data > answers data.
  # Any feature with required_fields should have a test like this. It verifies
  # that callers can always satisfy required fields via the data argument, regardless
  # of package state. This is the escape hatch when guessing fails.
  _test_explicit_data_override(
    :dependabot,
    Dict("PackageName" => "ExplicitPkgName"),
    joinpath(".github", "dependabot.yml"),
    "ExplicitPkgName";
    unexpected = "FakePkg",
  )
end

@testitem "add_feature(:changelog) generates CHANGELOG.md" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_happy_path(
    :changelog,
    ["CHANGELOG.md"];
    content_checks = Dict(
      "CHANGELOG.md" => ["Keep a Changelog", "Semantic Versioning", "## [Unreleased]"],
    ),
  )
end

@testitem "add_feature(:changelog) works without .copier-answers.yml when data is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  # Use light strategy so docs/make.jl exists and PackageOwner can be guessed
  _test_works_without_answers_by_guessing(
    :changelog,
    "CHANGELOG.md";
    generate_strategy = :light,
    expected_content = "Keep a Changelog",
  )
end

@testitem "add_feature(:changelog) errors when required fields are not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _test_errors_without_data(:changelog)
end

@testitem "add_feature(:changelog) uses explicit data over guessed values" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_explicit_data_override(
    :changelog,
    Dict("PackageOwner" => "ExplicitOwner", "PackageName" => "ExplicitPkg"),
    "CHANGELOG.md",
    "ExplicitOwner/ExplicitPkg.jl";
    unexpected = "FakePkg",
  )
end

@testitem "add_feature(:agents) generates AGENTS.md" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_happy_path(
    :agents,
    ["AGENTS.md"];
    content_checks = Dict("AGENTS.md" => ["FakePkg", "Pkg.test()"]),
  )
end

@testitem "add_feature(:agents) works without .copier-answers.yml when PackageName is guessable" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_works_without_answers_by_guessing(:agents, "AGENTS.md"; expected_content = "FakePkg")
end

@testitem "add_feature(:agents) errors when PackageName is not guessable" tags =
  [:unit, :fast, :error_handling] setup = [Common, AddFeatureHelpers] begin
  _test_errors_without_data(:agents)
end

@testitem "add_feature(:agents) uses explicit PackageName over guessed value" tags =
  [:integration, :slow, :template_application, :file_io, :python_integration] setup =
  [Common, AddFeatureHelpers] begin
  _test_explicit_data_override(
    :agents,
    Dict("PackageName" => "ExplicitPkgName"),
    "AGENTS.md",
    "ExplicitPkgName";
    unexpected = "FakePkg",
  )
end

@testitem "add_feature errors on unsupported feature symbol" tags = [:unit, :fast, :error_handling] setup =
  [Common, AddFeatureHelpers] begin
  _test_errors_without_data(:nonexistent_feature)
end

@testitem "features.toml ships with the package and is well-formed" tags = [:unit, :fast] begin
  using BestieTemplate

  # The bundled registry is the fallback for every add_feature call (and the
  # docstring is generated from it), so it must ship with the package.
  registry_path = joinpath(pkgdir(BestieTemplate), "features.toml")
  @test isfile(registry_path)

  features = BestieTemplate._load_features(registry_path)
  @test !isempty(features)
  for (name, spec) in features
    if haskey(spec, "alias_of")
      # Aliases have exactly one key and point to a non-alias feature
      @test collect(keys(spec)) == ["alias_of"]
      @test haskey(features, spec["alias_of"])
      @test !haskey(features[spec["alias_of"]], "alias_of")
    else
      for key in
          ["description", "forced_data", "included_files", "required_fields", "requires_answers"]
        @test haskey(spec, key)
      end
    end
  end

  # The docstring generator must produce the real list, not the error fallback
  @test contains(BestieTemplate._features_docstring(), ":pre_commit")
end

@testitem "add_feature handles .copier-answers.yml with a float-like _commit" tags =
  [:integration, :slow, :error_handling, :file_io] setup = [Common, AddFeatureHelpers] begin
  # Regression for the float-like `_commit` quirk handled by `_load_copier_answers`
  # (see its docstring). Generates a package, overwrites `_commit` with a git
  # short SHA that YAML parses as a float, and checks `add_feature` still works.
  _with_tmp_dir() do _
    _generate_pkg()
    answers = read(".copier-answers.yml", String)
    write(".copier-answers.yml", replace(answers, r"_commit: .*" => "_commit: 64e3774"))
    _add_feature_local(:pre_commit)
    @test isfile(".pre-commit-config.yaml")
  end
end
