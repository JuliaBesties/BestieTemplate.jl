# Questions

In this page we list all the questions of the template, in various formats.
Some of these questions are skipped because they are guessed.

To answer any of these question directly via the Julia API, you can pass a dictionary to the `generate` or `apply` functions.
For instance:

```@example
using BestieTemplate
cd(mktempdir()) do # hide
data = Dict(
  "PackageName" => "NotMyPkg",
  "PackageOwner" => "bestie",
  "Authors" => "Bestie",
)
BestieTemplate.generate(
  pkgdir(BestieTemplate), # hide
  "MyPkg",
  data,
  defaults=true, # Choose default for other questions - will fail if there is none
  quiet=true,
  vcs_ref="HEAD", # hide
)
print(read("MyPkg/Project.toml", String))
end # hide
```

!!! note "Help wanted"
    We have not managed to create a table of contents because we can't create the anchors in the headers. If you have an idea of what to do, help is appreciated.

## Table format

!!! note "Help wanted"
    We should have a single table and sortable columns. Probably done with external scripts, because injecting JS from here does not seem possible.

```@eval
using Printf, Markdown, YAML

struct Question
  name::String
  when::String
  type::String
  help::String
  default::String
  description::String

  section::String
  strategy::String

  function Question(name, content, section)
    when = get(content, "when", "")
    type = get(content, "type", "")
    help = get(content, "help", "")
    default = string(get(content, "default", ""))
    description = get(content, "description", "")

    m = match(r"Strategy: (.*)$", description)
    if isnothing(m)
      if section == "essential"
        strategy = "Tiny"
      elseif section == "strategy"
        strategy = "NA"
      else
        error("Unexpected section '$section'")
      end
    else
      strategy = m[1]
    end

    return new(name, when, type, help, default, description, section, strategy)
  end
end

sections = String[]
questions = Question[]

longest_name = 0

dir = joinpath(@__DIR__, "..", "..")

global JULIA_LTS_VERSION = ""

# Reading
for line in readlines(joinpath(dir, "copier.yml"))
  if startswith("!include")(line)
    file = split(line)[2]
    section_name = basename(file) |> x -> splitext(x)[1]
    if section_name == "constants"
      yaml = YAML.load_file(joinpath(dir, file))
      global JULIA_LTS_VERSION = yaml["JULIA_LTS_VERSION"]["default"]
      continue
    end
    push!(sections, section_name)
    yaml = YAML.load_file(joinpath(dir, file))
    for (name, content) in yaml
      if get(content, "when", true) != false
        global longest_name = max(longest_name, length(name))
        push!(questions, Question(name, content, section_name))
      end
    end
  end
end

# Processing
title_override = Dict("ci" => "Continuous Integration")
titles = Dict(
  section => get(title_override, section, section) |> x -> replace(x, "-" => " ") |> titlecase for
  section in sections
)

# Ordering functions
strategy_lookup = Dict(
  "Tiny" => 0,
  "Light" => 1,
  "Moderate" => 2,
  "Robust" => 3,
  "Advanced" => 4,
  "NA" => 99,
  "none" => 99,
)
order_by_strategy = q -> (strategy_lookup[q.strategy], q.section, q.name)
order_by_section = q -> (q.section, strategy_lookup[q.strategy], q.name)

# Printing
io = IOBuffer()

for (ordering_section, ordering_function) in [
  (
    "### Questions ordered by strategy level",
    order_by_strategy,
  ),
  (
    "### Questions ordered by section name",
    order_by_section,
  )
]
  println(io, ordering_section)
  sort!(questions; by = ordering_function)
  table_row_fmt = Printf.Format("| %-$(longest_name)s | %15s | %15s | %45s |")
  println(io, Printf.format(table_row_fmt, "Question name", "Section", "Strategy", "Default"))
  println(io, Printf.format(table_row_fmt, "-"^longest_name, ":" * "-"^14, ":" * "-"^14, ":" * "-"^44))
  for question in questions
    default = contains(question.default, "Default") ? "depends on strategy" : question.default
    if question.name == "PackageUUID"
      default = "Random UUID"
    elseif question.name == "LicenseCopyrightHolders"
      default = "Authors"
    elseif question.name == "JuliaMinVersion"
      default = "LTS version (Currently $JULIA_LTS_VERSION)"
    elseif question.name == "JuliaMinCIVersion"
      default = "lts or JuliaMinVersion"
    elseif question.name == "CodeOfConductContact"
      default = "Authors' e-mail"
    elseif question.name == "ExplicitImportsChecklist"
      default = "`" * question.default * "`"
    end
    println(io, Printf.format(table_row_fmt, question.name, question.section, question.strategy, default))
  end

end
out = String(take!(io))

Markdown.parse(out)
```

## Ordered list

```@eval
using Markdown, YAML

sections = String[]
questions = Dict{String,Any}()

dir = joinpath(@__DIR__, "..", "..")

out = ""

for line in readlines(joinpath(dir, "copier.yml"))
  if startswith("!include")(line)
    file = split(line)[2]
    section_name = basename(file) |> x -> splitext(x)[1]
    if section_name == "constants"
      continue
    end
    push!(sections, section_name)
    yaml = YAML.load_file(joinpath(dir, file))
    questions[section_name] = yaml
  end
end

title_override = Dict(
  "ci" => "Continuous Integration",
)
titles = Dict(
  section => get(title_override, section, section) |> x -> replace(x, "-" => " ") |> titlecase
  for section in sections
)

for section in sections
  global out
  title = titles[section]
  out *= "## Section: $title\n\n"
  for question in questions[section]
    name, answers = question
    if haskey(answers, "when") && answers["when"] == false
      continue
    end
    out *= "### $name\n\n"

    if !haskey(answers, "help")
      @info answers["when"]
      error("Key 'help' not found for '$name'")
    end
    help = answers["help"]
    out *= "**Question (in the CLI)**: $help\n\n"

    description = get(answers, "description", "")
    if description != ""
      out *= "**Description:**\n"
      out *= join("> " .* split(description, "\n"), "\n>\n")
    end

    out *= "\n\n"
  end
end

Markdown.parse(out)
```
