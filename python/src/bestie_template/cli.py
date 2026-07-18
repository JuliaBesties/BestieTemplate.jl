"""The `bestie` CLI: a thin typer frontend over the L2 operations.

No logic beyond argument parsing and presentation lives here — results and
typed errors come from :mod:`bestie_template` (see design/04-frontends.md).
"""

from __future__ import annotations

import dataclasses
import json
import sys
from importlib.metadata import version as _dist_version
from typing import Annotated

import typer

import bestie_template
from copier_features.errors import CopierFeaturesError, MissingRequiredFieldsError

app = typer.Typer(
    help="Add BestieTemplate features to Julia packages, without installing Julia.",
    no_args_is_help=True,
    add_completion=False,
)

RefOption = Annotated[
    str | None,
    typer.Option(
        "--ref",
        help="Git ref of the template (e.g. v0.19.0); defaults to the latest template release.",
    ),
]
TemplateOption = Annotated[
    str | None,
    typer.Option(
        "--template",
        help=f"Template URL or local path (default: {bestie_template.TEMPLATE_URL}).",
    ),
]
JsonOption = Annotated[
    bool,
    typer.Option("--json", help="Emit machine-readable JSON (for results and errors alike)."),
]


def _fail(exc: CopierFeaturesError, as_json: bool) -> None:
    missing = exc.missing if isinstance(exc, MissingRequiredFieldsError) else ()
    if as_json:
        error = {"type": type(exc).__name__, "message": str(exc)}
        if missing:
            error["missing"] = list(missing)
        print(json.dumps({"error": error}))
    else:
        print(f"Error: {exc}", file=sys.stderr)
        if missing:
            hint = " ".join(f"-d {field}=..." for field in missing)
            print(f"Hint: pass the missing values on the command line: {hint}", file=sys.stderr)
    raise typer.Exit(code=1)


def _parse_data(pairs: list[str] | None) -> dict[str, str]:
    data: dict[str, str] = {}
    for pair in pairs or []:
        key, sep, value = pair.partition("=")
        if not sep or not key:
            raise typer.BadParameter(f"expected KEY=VALUE, got {pair!r}", param_hint="--data")
        data[key] = value
    return data


def _version_callback(value: bool) -> None:
    if value:
        print(_dist_version("bestie-template"))
        raise typer.Exit()


@app.callback()
def _main(
    version: Annotated[
        bool,
        typer.Option(
            "--version", callback=_version_callback, is_eager=True, help="Print the version."
        ),
    ] = False,
) -> None:
    pass


@app.command("add-feature")
def add_feature(
    features: Annotated[
        str,
        typer.Argument(
            help="Comma-separated feature names, applied in order (e.g. agents,testitem_cli)."
        ),
    ],
    path: Annotated[str, typer.Argument(help="Package directory to apply the features to.")] = ".",
    data: Annotated[
        list[str] | None,
        typer.Option(
            "--data",
            "-d",
            metavar="KEY=VALUE",
            help="Answer a template question; repeatable. Example: -d PackageName=MyPkg",
        ),
    ] = None,
    ref: RefOption = None,
    template: TemplateOption = None,
    as_json: JsonOption = False,
) -> None:
    """Apply one or more template features to an existing package."""
    if features.rstrip().endswith(",") and path != ".":
        # `bestie add-feature X,Y, Z`: the shell splits on the space, so "Z"
        # would silently become the destination PATH
        merged = "".join((features + path).split())
        raise typer.BadParameter(
            f"features must be one comma-separated argument without spaces, but got "
            f"{features!r} followed by PATH {path!r} — did you mean {merged!r}?",
            param_hint="FEATURES",
        )
    names = [name for name in (part.strip() for part in features.split(",")) if name]
    if not names:
        raise typer.BadParameter("no feature names given", param_hint="FEATURES")
    try:
        result = bestie_template.add_feature(
            names, path, data=_parse_data(data), ref=ref, template=template
        )
    except CopierFeaturesError as exc:
        _fail(exc, as_json)
        return
    if as_json:
        print(json.dumps(dataclasses.asdict(result)))
        return
    print(f"Applied {len(result.applied)} feature(s) to {result.dst}:")
    for applied in result.applied:
        alias = "" if applied.name == applied.resolved_name else f" (-> {applied.resolved_name})"
        print(f"  {applied.name}{alias}: {', '.join(applied.files)}")
    if result.answers_file_updated:
        print("Updated .copier-answers.yml with the merged answers.")
    else:
        print("No .copier-answers.yml in the destination; none was created.")


@app.command("list-features")
def list_features(
    ref: RefOption = None,
    template: TemplateOption = None,
    as_json: JsonOption = False,
) -> None:
    """List the features that add-feature can apply."""
    try:
        features = bestie_template.list_features(ref=ref, template=template)
    except CopierFeaturesError as exc:
        _fail(exc, as_json)
        return
    if as_json:
        print(json.dumps([dataclasses.asdict(feature) for feature in features]))
        return
    width = max(len(feature.name) for feature in features)
    for feature in features:
        text = (
            f"alias of {feature.alias_of}" if feature.alias_of is not None else feature.description
        )
        print(f"{feature.name:<{width}}  {text}")
