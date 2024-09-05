"""
Fake data for testing

- `Debug.Data`: NamedTuple of Dictionaries with default data
  - `Debug.Data.minimum_defaults`: Required data if you use `defaults = true`
  - `Debug.Data.strategy_minimum`: Required data for strategy minimum, no defaults.
  - `Debug.Data.strategy_recommended`: Required data for strategy recommended, no defaults.
  - `Debug.Data.strategy_ask`: Required data for strategy ask, no defaults.
"""
module Data

using Random: MersenneTwister
using UUIDs: uuid4

const minimum_defaults = Dict(
  "PackageName" => "FakePkg",
  "PackageUUID" => string(uuid4(MersenneTwister(123))),
  "PackageOwner" => "bestietemplate",
  "AuthorName" => "Bestie Template",
  "AuthorEmail" => "bestie@fake.nl",
)

const strategy_minimum = merge(
  minimum_defaults,
  Dict(
    "JuliaMinVersion" => "1.6",
    "License" => "MIT",
    "LicenseCopyrightHolders" => "Bestie Template",
    "Indentation" => 4,
    "AnswerStrategy" => "minimum",
  ),
)

const strategy_recommended = merge(strategy_minimum, Dict("AnswerStrategy" => "recommended"))

const strategy_ask = merge(strategy_recommended, Dict("AnswerStrategy" => "ask"))

const optional_questions_with_default = Dict(
  "AddPrecommit" => true,
  "AutoIncludeTests" => true,
  "JuliaMinCIVersion" => "lts",
  "AddMacToCI" => true,
  "AddWinToCI" => true,
  "RunJuliaNightlyOnCI" => true,
  "UseCirrusCI" => false,
  "AddCopierCI" => false,
  "AddContributionDocs" => true,
  "AddAllcontributors" => true,
  "AddCodeOfConduct" => true,
  "CodeOfConductContact" => strategy_minimum["AuthorEmail"],
  "AddGitHubTemplates" => true,
)

const strategy_ask_default = merge(strategy_ask, optional_questions_with_default)

const strategy_ask_and_say_no =
  merge(strategy_recommended, Dict(k => false for k in keys(optional_questions_with_default)))

const strategy_ask_and_say_yes =
  merge(strategy_recommended, Dict(k => true for k in keys(optional_questions_with_default)))

end
