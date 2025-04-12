"""
Fake data for testing

- `Debug.Data.strategies`: NamedTuple of Dictionaries with default data
"""
module Data

using Random: MersenneTwister
using UUIDs: uuid4

const strategies = let
  deprecated = Dict()

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
      "AddWinToCI" => true,
      "AutoIncludeTests" => true,
      "CheckExplicitImports" => true,
      "CodeOfConductContact" => split(moderate["Authors"], ",")[1],
      "ExplicitImportsChecklist" => "all",
      "RunJuliaNightlyOnCI" => true,
      "StrategyLevel" => 3,
      "UseCirrusCI" => false,
    ),
  )

  (; deprecated, tiny, light, moderate, robust)
end

end
