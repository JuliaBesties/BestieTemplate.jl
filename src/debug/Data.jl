"""
Fake data for testing

- `Debug.Data.strategies`: NamedTuple of Dictionaries with default data
"""
module Data

using Random: MersenneTwister
using UUIDs: uuid4

const strategies = let
  deprecated = Dict()

  minimalistic = merge(
    deprecated,
    Dict(
      "Authors" => "Bestie Template <bestie@fake.nl> and contributors",
      "JuliaIndentation" => 4,
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

  light = merge(minimalistic, Dict("StrategyLevel" => 1))

  moderate = merge(light, Dict("StrategyLevel" => 2))

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
      "ConfigIndentation" => 2,
      "ExplicitImportsChecklist" => "all",
      "MarkdownIndentation" => 2,
      "RunJuliaNightlyOnCI" => true,
      "StrategyLevel" => 3,
      "UseCirrusCI" => false,
    ),
  )

  (; deprecated, minimalistic, light, moderate, robust)
end

end
