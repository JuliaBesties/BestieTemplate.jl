var documenterSearchIndex = {"docs":
[{"location":"20-explanation/#explanation","page":"Explanation","title":"Explanation","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"In this section, we hope to explain the motivation for the package, and what is inside the template. Some things might have been obvious when creating the package and not at the moment, so feel free to create issues to ask, or suggest, clarifications.","category":"page"},{"location":"20-explanation/#The-engine,-the-project-generator,-and-the-template","page":"Explanation","title":"The engine, the project generator, and the template","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Let me start by marking some names clearer.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"The template is the collection of files and folders written with some placeholders. For instance, the link to a GitHub project will be something like https://github.com/{{ PackageOwner }}/{{ PackageName }}.jl.\nThe engine is the tool that converts the template into the end result, by changing the placeholders into the actual values that we want.\nThe project generator is the tool that interacts with the user to get the placeholder values and give to the engine.","category":"page"},{"location":"20-explanation/#Comparison-with-existing-solutions","page":"Explanation","title":"Comparison with existing solutions","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Julia has a very good package generator called PkgTemplates.jl, so why did we create another one?","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"The short answer is that we want a more streamlined development experience, a template more focused on best practices, and the ability to keep reusing the template whenever new tools and ideas are implemented.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"In more details, first, see the differences in the parts of the project in the table below:","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":" COPIERTemplate.jl PkgTemplates.jl\nTemplate Part of the package Part of the package\nEngine Jinja Mustache\nProject generator copier, with some wrappers in the package Part of the package","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Now, we can split this into three comparisons.","category":"page"},{"location":"20-explanation/#Template-differences","page":"Explanation","title":"Template differences","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"The template differences are mostly due to opinion and contributions and it should be easy to translate files from one template to the other. We are heavily inspired by PkgTemplates.jl, as we used it for many years, but we made some changes in the hopes of improving software sustainability, package maintainability and code quality (which we just overtly simplify as best practices). As such, our current differences (as of the time of writing) are:","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"We have more best practices tools, such as pre-commit, configuration for linters and formatters for Julia, Markdown, TOML, YAML and JSON, CITATION.cff, Lint GitHub workflow, .editorconfig file, issues and pull requests templates, etc.\nWe focus on the main use cases (GitHub and GitHub actions), so we have much less options.","category":"page"},{"location":"20-explanation/#Engine-differences","page":"Explanation","title":"Engine differences","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"We can't say much about these, since we don't know or care in details.","category":"page"},{"location":"20-explanation/#Project-generator-differences","page":"Explanation","title":"Project generator differences","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"PkgTemplates.jl is a project generator. This means that if you want to programmatically create templates inside Julia, this is the best solution. The questions (user interface) are implemented by the package, which then translates that into the answers for the engine. Disclaimer: We haven't worked on the package, this information is based on the docs.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"We use copier as project generator. It is an external Python tool, so we also include some wrappers in the package to use it from Julia without the need to explicitly install it. Copier has many features, so we recommend that you check their comparisons pages for more information.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Most notably, the feature that made us choose copier in the first place has the ability to applied and reapplied to existing projects. This means that existing packages can benefit from all best practices that we provide. Furthermore, they can keep reaping benefits when we create new versions of the template.","category":"page"},{"location":"20-explanation/#Template-details","page":"Explanation","title":"Template details","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Let's dive into the details of the template now.","category":"page"},{"location":"20-explanation/#Basic-package-structure","page":"Explanation","title":"Basic package structure","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"This is the basic structure of a package:","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"PackageName.jl/\nsrc/\nPackageName.jl\ntest/\nProject.toml\nruntests.jl\nLICENSE.md\nProject.toml\nREADME.md","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"With the exception of test/Project.toml, all other files are requirements to register a package.","category":"page"},{"location":"20-explanation/#Documentation","page":"Explanation","title":"Documentation","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"On top of the basic structure, we add some Documenter.jl structure.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"docs/\nsrc/\n90-contributing.md\n90-developer.md\n90-reference.md\nindex.md\nmake.jl\nProject.toml","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Brief explanation of the details:","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"The Project.toml, make.jl and src/index.md are the basic structure.\ndocs/src/90-contributing.md: Sometimes added as CONTRIBUTING.md, it explains how contributors can get involved in the project.\ndocs/src/90-developer.md: Sometimes added as README.dev.md or DEVELOPER.md, it explains how to setup your local environment and other information relevant for developers only.\ndocs/src/90-reference.md is the API reference page, which include an @autodocs.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"One noteworthy aspect of our make.jl, is that we include some code to automatically generate the list of pages. Create a file in the form ##-name.md, where ## is a two-digit number, and it will be automatically added to the pages list.","category":"page"},{"location":"20-explanation/#Linting-and-Formatting","page":"Explanation","title":"Linting and Formatting","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"The most important file related to linting and formatting is .pre-commit-config.yaml, which is the configuration for pre-commit. It defines a list of linters and formatters for Julia, Markdown, TOML, YAML, and JSON.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"It requires installing pre-commit (I recommend installing it globally with pipx). Installing pre-commit (pre-commit install) will make sure that it runs the relevant hooks before committing. Furthermore, if you run pre-commit run -a, it runs all hooks.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Some hooks in the .pre-commit-config.yaml file have configuration files of their own: .JuliaFormatter.toml, .markdownlint.json, .markdown-link-config.json, and .yamllint.yml.","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"Also slightly related, is the .editorconfig file, which tells your editor, if you install the correct plugin, how to format some things.","category":"page"},{"location":"20-explanation/#GitHub-Workflows","page":"Explanation","title":"GitHub Workflows","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"We have a few workflows, with plans to expand in the future:","category":"page"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"CompatHelper.yml: Should be well known by now. It checks that your Project.toml compat entries are up-to-date.\nCopier.yml: This will periodically check the template for updates. If there are updates, this action creates a pull request updating your repo.\nDocs.yml: Build the docs. Only runs when relevant files change.\nLint.yml: Run the linter and formatter through the command pre-commit run -a.\nTagBot.yml: Create GitHub releases automatically after your new release is merged on the Registry.\nTest.yml: Run the tests.","category":"page"},{"location":"20-explanation/#Issues-and-PR-templates","page":"Explanation","title":"Issues and PR templates","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":"We include issues and PR templates for GitHub (see .github/). These provide a starting point to your project management.","category":"page"},{"location":"20-explanation/#Other-files","page":"Explanation","title":"Other files","text":"","category":"section"},{"location":"20-explanation/","page":"Explanation","title":"Explanation","text":".cirrus.yml: For Cirrus CI, which we use solely for FreeBSD testing.\nCITATION.cff: Instead of the more classic .bib, we use .cff, which serves a better purpose of providing the metadata of the package. CFF files have been adopted by GitHub, so you can generate a BibTeX entry by clicking on \"Cite this repository\" on the repository's main page. CFF files have also been adopted by Zenodo to provide the metadata of your deposition.\nCODE_OF_CONDUCT.md: A code of conduct file from Contributor Covenant.","category":"page"},{"location":"90-contributing/#contributing","page":"Contributing","title":"Contributing guidelines","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"First of all, thanks for the interest!","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"We welcome all kinds of contribution, including, but not limited to code, documentation, examples, configuration, issue creating, etc.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"Be polite and respectful and follow the code of conduct.","category":"page"},{"location":"90-contributing/#Bug-reports-and-discussions","page":"Contributing","title":"Bug reports and discussions","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If you think you found a bug, feel free to open an issue. Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.","category":"page"},{"location":"90-contributing/#Working-on-an-issue","page":"Contributing","title":"Working on an issue","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If you found an issue that interests you, comment on that issue what your plans are. If the solution to the issue is clear, you can immediately create a pull request (see below). Otherwise, say what your proposed solution is and wait for a discussion around it.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"TipFeel free to ping us after a few days if there are no responses.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If your solution involves code (or something that requires running the package locally), check the developer documentation. Otherwise, you can use the GitHub interface directly to create your pull request.","category":"page"},{"location":"90-developer/#dev_docs","page":"Developer docs","title":"Developer documentation","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If you haven't, please read the Contributing guidelines first.","category":"page"},{"location":"90-developer/#Linting-and-formatting","page":"Developer docs","title":"Linting and formatting","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Install a plugin on your editor to use EditorConfig. This will ensure that your editor is configured with important formatting settings.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"We use https://pre-commit.com to run the linters and formatters. In particular, the Julia code is formatted using JuliaFormatter.jl, so please install it globally first.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"To install pre-commit, we recommend using pipx as follows:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"# Install pipx following the link\npipx install pre-commit","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"With pre-commit installed, activate it as a pre-commit hook:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"pre-commit install","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"To run the linting and formatting manually, enter the command below:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"pre-commit run -a","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Now, you can only commit if all the pre-commit tests pass.","category":"page"},{"location":"90-developer/#First-time-clone","page":"Developer docs","title":"First time clone","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If this is the first time you work with this repository, follow the instructions below to clone the repository.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Fork this repo\nClone your repo (this will create a git remote called origin)\nAdd this repo as a remote:\ngit remote add orgremote https://github.com/abelsiqueira/COPIERTemplate.jl","category":"page"},{"location":"90-developer/#Working-on-a-new-issue","page":"Developer docs","title":"Working on a new issue","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Fetch from the JSO remote and fast-forward your local main\ngit fetch orgremote\ngit switch main\ngit merge --ff-only orgremote/main\nBranch from main to address the issue (see below for naming)\ngit switch -c 42-add-answer-universe\nPush the new local branch to your personal remote repository\ngit push -u origin 42-add-answer-universe\nCreate a pull request to merge your remote branch into the org main.","category":"page"},{"location":"90-developer/#Branch-naming","page":"Developer docs","title":"Branch naming","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If there is an associated issue, add the issue number.\nIf there is no associated issue, and the changes are small, add a prefix such as \"typo\", \"hotfix\", \"small-refactor\", according to the type of update.\nIf the changes are not small and there is no associated issue, then create the issue first, so we can properly discuss the changes.\nUse dash separated imperative wording related to the issue (e.g., 14-add-tests, 15-fix-model, 16-remove-obsolete-files).","category":"page"},{"location":"90-developer/#Commit-message","page":"Developer docs","title":"Commit message","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Use imperative or present tense, for instance: Add feature or Fix bug.\nHave informative titles.\nIf necessary, add a body with details.","category":"page"},{"location":"90-developer/#Before-creating-a-pull-request","page":"Developer docs","title":"Before creating a pull request","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"[Advanced] Try to create \"atomic git commits\" (recommended reading: The Utopic Git History).\nMake sure the tests pass.\nMake sure the pre-commit tests pass.\nFetch any main updates from upstream and rebase your branch, if necessary:\nbash  git fetch orgremote  git rebase orgremote/main BRANCH_NAME\nThen you can open a pull request and work with the reviewer to address any issues.","category":"page"},{"location":"90-developer/#Tips","page":"Developer docs","title":"Tips","text":"","category":"section"},{"location":"90-developer/#Testing-local-changes","page":"Developer docs","title":"Testing local changes","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"To test you local modifications, you can run copier with the --vcs-ref HEAD flag and point to your local clone. This will use the latest changes, including uncommitted modifications (i.e., the dirty state). What I normally do is this:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"cd $(mktemp -d) # Go to a tmp folder\ncopier copy --vcs-ref HEAD /path/to/clone/ pkg # Clone dirty clone into pkg","category":"page"},{"location":"90-reference/#reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"90-reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Pages = [\"90-reference.md\"]","category":"page"},{"location":"90-reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Pages = [\"90-reference.md\"]","category":"page"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Modules = [COPIERTemplate]","category":"page"},{"location":"90-reference/#COPIERTemplate.generate","page":"Reference","title":"COPIERTemplate.generate","text":"generate(path, generate_missing_uuid = true; kwargs...)\n\nRuns the copy command of copier with the COPIERTemplate template. Even though the template is available offline through this template, this uses the github URL to allow updating.\n\nThe keyword arguments are passed directly to the run_copy function of copier. If generate_missing_uuid is true and there is no kwargs[:data][\"PackageUUID\"], then a UUID is generated for the package.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = COPIERTemplate","category":"page"},{"location":"#COPIERTemplate-Copier-OPInionated-Evolving-Reusable-Template","page":"Home","title":"COPIERTemplate - Copier OPInionated Evolving Reusable Template","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: COPIERTemplate.jl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation of COPIERTemplate.jl. This package provides a template in the copier engine for a Julia package. Furthermore, it provides a wrapper around convenience calls to that package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main features of this package/template are:","category":"page"},{"location":"","page":"Home","title":"Home","text":"It provides a curated (opinionated) list of tools and best practices for Julia package development;\nIt can be applied and reapplied to existing packages, allowing the updates in the template to be imported into the package;","category":"page"},{"location":"#Using","page":"Home","title":"Using","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To fully benefit from the template, there are some steps to be done before and after you generate your package. Check the full guide for more details.","category":"page"},{"location":"","page":"Home","title":"Home","text":"However, if you kinda know what you need to do, this is the TL;DR:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using COPIERTemplate\njulia> COPIERTemplate.generate(\"YourPackage.jl\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Or, alternatively, using copier, run","category":"page"},{"location":"","page":"Home","title":"Home","text":"copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"I really recommend checking the full guide, though.","category":"page"},{"location":"","page":"Home","title":"Home","text":"To understand more about our motivation and what the template provides, check the explanation page.","category":"page"},{"location":"#Getting-and-providing-help","page":"Home","title":"Getting and providing help","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"I hope you find this package useful. If you have any questions, requests, or comments, check the issues and discussion pages.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you would like to get involved in the COPIERTemplate growth, please check our contributing guide. We welcome contributions of many types, including coding, reviewing, creating issues, creating tutorials, interacting with users, etc. Make sure to follow our code of conduct.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If your interest is in developing the package, check the development guide as well.","category":"page"},{"location":"#Contributors","page":"Home","title":"Contributors","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"<!-- markdown-link-check-disable -->\n\n<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->\n<!-- prettier-ignore-start -->\n<!-- markdownlint-disable -->\n<table>\n  <tbody>\n    <tr>\n      <td align=\"center\" valign=\"top\" width=\"14.28%\"><a href=\"https://abelsiqueira.com\"><img src=\"https://avatars.githubusercontent.com/u/1068752?v=4?s=100\" width=\"100px;\" alt=\"Abel Soares Siqueira\"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href=\"#code-abelsiqueira\" title=\"Code\">💻</a> <a href=\"#projectManagement-abelsiqueira\" title=\"Project Management\">📆</a> <a href=\"#doc-abelsiqueira\" title=\"Documentation\">📖</a> <a href=\"#maintenance-abelsiqueira\" title=\"Maintenance\">🚧</a></td>\n      <td align=\"center\" valign=\"top\" width=\"14.28%\"><a href=\"http://tmigot.github.io\"><img src=\"https://avatars.githubusercontent.com/u/25304288?v=4?s=100\" width=\"100px;\" alt=\"Tangi Migot\"/><br /><sub><b>Tangi Migot</b></sub></a><br /><a href=\"#code-tmigot\" title=\"Code\">💻</a> <a href=\"#doc-tmigot\" title=\"Documentation\">📖</a></td>\n      <td align=\"center\" valign=\"top\" width=\"14.28%\"><a href=\"https://pabrod.github.io/\"><img src=\"https://avatars.githubusercontent.com/u/7677614?v=4?s=100\" width=\"100px;\" alt=\"Pablo Rodríguez-Sánchez\"/><br /><sub><b>Pablo Rodríguez-Sánchez</b></sub></a><br /><a href=\"#doc-PabRod\" title=\"Documentation\">📖</a></td>\n      <td align=\"center\" valign=\"top\" width=\"14.28%\"><a href=\"https://www.esciencecenter.nl/\"><img src=\"https://avatars.githubusercontent.com/u/15750539?v=4?s=100\" width=\"100px;\" alt=\"Olga Lyashevska\"/><br /><sub><b>Olga Lyashevska</b></sub></a><br /><a href=\"#code-lyashevska\" title=\"Code\">💻</a> <a href=\"#doc-lyashevska\" title=\"Documentation\">📖</a></td>\n      <td align=\"center\" valign=\"top\" width=\"14.28%\"><a href=\"https://luisaforozco.github.io/\"><img src=\"https://avatars.githubusercontent.com/u/99738896?v=4?s=100\" width=\"100px;\" alt=\"Luisa Orozco\"/><br /><sub><b>Luisa Orozco</b></sub></a><br /><a href=\"#code-luisaforozco\" title=\"Code\">💻</a> <a href=\"#doc-luisaforozco\" title=\"Documentation\">📖</a></td>\n    </tr>\n  </tbody>\n</table>\n\n<!-- markdownlint-restore -->\n<!-- prettier-ignore-end -->\n\n<!-- ALL-CONTRIBUTORS-LIST:END -->\n","category":"page"},{"location":"10-full-guide/#full_guide","page":"Full Guide","title":"Full guide","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Welcome to full usage guide of COPIERTemplate.","category":"page"},{"location":"10-full-guide/#Before-installing","page":"Full Guide","title":"Before installing","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"We highly recommend that you install pre-commit. Our whole linting is based on that tool, so you might want to adopt it locally.\nDecide if you are going to install copier or use our Julia interface.\nIf you use copier directly, find a UUID version 4 generator.\nOn Linux and MacOS, you can run uuidgen\nOn Julia, you can run using UUIDs; uuid4()\nOnline, you can try uuidgenerator.net","category":"page"},{"location":"10-full-guide/#Installation","page":"Full Guide","title":"Installation","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"To install with COPIERTemplate.jl, install the package, use it, and run COPIERTemplate.generate(path).","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Alternatively, this can also be installed directly via copier, with the command","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"copier copy https://github.com/abelsiqueira/COPIERTemplate.jl YourPackage.jl","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Many questions will be asked. The explanation on them should be sufficient (if they aren't, please let us know).","category":"page"},{"location":"10-full-guide/#Post-installation","page":"Full Guide","title":"Post-installation","text":"","category":"section"},{"location":"10-full-guide/#Add-to-GitHub","page":"Full Guide","title":"Add to GitHub","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"The resulting folder will not be a git package yet (to avoid trust issues), so you need to handle that yourself. Here is a short example:","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"cd YourPackage.jl\ngit init\ngit add .\npre-commit run -a # Try to fix possible pre-commit issues (failures are expected)\ngit add .\ngit commit -m \"First commit\"\npre-commit install # Future commits can't be directly to main unless you use -n","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"It is common to have some pre-commit issues due to your package's name length triggering JuliaFormatter.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Create a repo on GitHub and push your code to it.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"info: Info\nThe actions will run and you will see errors in the documentation and linting. Do not despair.","category":"page"},{"location":"10-full-guide/#Documentation","page":"Full Guide","title":"Documentation","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Go to your package setting on Github and find the \"Actions\" tab, the \"General\" link. On that page, find the \"Workflow permissions\" and change the selection to \"Read and write permissions\", and enable \"Allow GitHub Actions can create and approve pull requests\". This will allow the documentation workflow to work for development.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Go to the Actions page, click the failing Docs workflow and click on \"re-run all jobs\". It should pass now.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Now, go to your package setting on GitHub and find the \"Pages\" link. You should see an option to set the Source to \"Deploy from a branch\", and select the branch to be \"gh-pages\" and to deploy from the \"/ (root)\".","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"After circa 1 minute, you can check that the documentation was built properly.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"info: Info\nAt this point, you should have passing workflows.Tests should have been passing from the start.\nLint was fixed when we pushed the code to GitHub.\nDocs was fixed with the permissions change.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"You will still need to set a DOCUMENTER_KEY to build the documentation from the tags automatically when using TagBot (which we do by default). Do the following:","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"pkg> activate --temp\npkg> add DocumenterTools\njulia> using DocumenterTools\njulia> DocumenterTools.genkeys(user=\"UserName\", repo=\"PackageName.jl\")","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Follow the instruction in the terminal.","category":"page"},{"location":"10-full-guide/#Add-key-for-Copier.yml-workflow-(or-delete-it)","page":"Full Guide","title":"Add key for Copier.yml workflow (or delete it)","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"You can reapply the template in the future. This is normally a manual job, specially because normally there are conflicts. That being said, we are experimenting with having a workflow that automatically checks whether there are updates to the template and reapplies it. A Pull Request is created with the result.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"warning: Warning\nThis is optional, and in development, so you might want to delete the workflow instead.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"If you decide to use, here are the steps to set it up:","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Create a Personal Access Token to be used by the Copier workflow.\nGo to https://github.com/settings/tokens.\nCreate a token with \"Content\", \"Pull-request\", and \"Workflows\" permissions.\nCopy the Token.\nGo to your YOUR_PACKAGE_URL/settings/secrets/actions.\nCreate a \"New repository secret\" named COPIER_PAT.","category":"page"},{"location":"10-full-guide/#CITATION.cff-and-Zenodo-deposition","page":"Full Guide","title":"CITATION.cff and Zenodo deposition","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Update your CITATION.cff file with correct information. You can use cffinit to generate it easily.","category":"page"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Before releasing, enable Zenodo integration at https://zenodo.org/account/settings/github/ to automatically generate a deposition of your package, i.e., archive a version on Zenodo and generate a DOI.","category":"page"},{"location":"10-full-guide/#Update-README.md","page":"Full Guide","title":"Update README.md","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Update the badges\nAdd a description","category":"page"},{"location":"10-full-guide/#Enable-discussions","page":"Full Guide","title":"Enable discussions","text":"","category":"section"},{"location":"10-full-guide/","page":"Full Guide","title":"Full Guide","text":"Enable GitHub discussions.","category":"page"}]
}
