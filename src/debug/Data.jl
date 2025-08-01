"""
Fake data for testing

- `Debug.Data.strategies`: NamedTuple of Dictionaries with default data
"""
module Data

using Random: MersenneTwister
using UUIDs: uuid4

const strategies = let
  deprecated = Dict()

  # TODO: I don't remember if this is required to be a comprehensive definition
  # of all answers of tiny, or if default values can/should be skipped. This
  # was not a roadblock until TestingStrategy was introduced, because
  # TestingStrategy has different default values depending on the Strategy
  # used. In other words, TestingStrategy is the only option that appears
  # explicitly in more than one strategy (except for StrategyLevel itself).
  # I feel like explicitly defining TestingStrategy in both places is the
  # correct solution. The recopy test was affected by this.
  tiny = merge(
    deprecated,
    Dict(
      "Authors" => "Bestie Template <bestie@fake.nl> and contributors",
      "JuliaMinCIVersion" => "lts",
      "JuliaMinVersion" => "1.10",
      "License" => "MIT",
      "LicenseCopyrightHolders" => "Bestie Template",
      "PackageName" => "FakePkg",
      "PackageOwner" => "bestietemplate",
      "PackageUUID" => string(uuid4(MersenneTwister(123))),
      "StrategyConfirmIncluded" => true,
      "StrategyLevel" => 0,
      "StrategyReviewExcluded" => false,
      "TestingStrategy" => "basic",
    ),
  )

  light = merge(
    tiny,
    Dict(
      "AddCompatHelperCI" => true,
      "AddDocs" => true,
      "AddDocsCI" => true,
      "AddFormatterAndLinterConfigFiles" => true,
      "AddGitHubPRTemplate" => true,
      "AddLychee" => true,
      "AddTagBotCI" => true,
      "AddTestCI" => true,
      "ConfigIndentation" => 2,
      "JuliaIndentation" => 4,
      "MarkdownIndentation" => 2,
      "StrategyLevel" => 1,
      "TestingStrategy" => "testitem_basic",
    ),
  )

  moderate = merge(
    light,
    Dict(
      "AddCitationCFF" => true,
      "AddDependabot" => true,
      "AddLintCI" => true,
      "StrategyLevel" => 2,
    ),
  )

  robust = merge(
    moderate,
    Dict(
      "AddAllcontributors" => true,
      "AddCodeOfConduct" => true,
      "AddContributionDocs" => true,
      "AddCopierCI" => false,
      "AddGitHubTemplates" => true,
      "AddMacToCI" => true,
      "AddPrecommit" => true,
      "AddPrecommitUpdateCI" => true, # actually part of advanced
      "AddWinToCI" => true,
      "CheckExplicitImports" => true, # actually part of advanced
      "CodeOfConductContact" => split(moderate["Authors"], ",")[1],
      "ExplicitImportsChecklist" => "all", # actually part of advanced
      "RunJuliaNightlyOnCI" => true,
      "StrategyLevel" => 3,
      "UseCirrusCI" => false,
    ),
  )

  (; deprecated, tiny, light, moderate, robust)
end

end
