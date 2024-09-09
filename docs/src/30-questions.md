# Questions

In this page we list all the questions of the template, in the order that they are asked.
Some of these questions are skipped because they are guessed.

To answer any of these question via the Julia interface, you can pass a dictionary to the `generate` or `apply` functions.
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
    out *= "### $name\n\n"

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
