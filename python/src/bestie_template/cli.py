"""The `bestie` CLI: argument parsing and printing over the bestie_template API."""

from __future__ import annotations

import json
from importlib.metadata import version as _package_version
from typing import Annotated

import typer

from . import TEMPLATE_URL, BestieError, add_feature, list_features

app = typer.Typer(
    help="Add BestieTemplate features to Julia packages, without installing Julia.",
    no_args_is_help=True,
    add_completion=False,
    pretty_exceptions_enable=False,
)

JsonOption = Annotated[bool, typer.Option("--json", help="Emit machine-readable JSON.")]


def _show_version(value: bool) -> None:
    if value:
        typer.echo(_package_version("bestie-template"))
        raise typer.Exit()


def _fail(exc: BestieError, as_json: bool) -> typer.Exit:
    """Report a failed operation and stop with exit code 1."""
    if as_json:
        typer.echo(json.dumps({"error": str(exc)}))
    else:
        typer.echo(f"Error: {exc}", err=True)
    return typer.Exit(code=1)


@app.callback()
def main(
    version: Annotated[
        bool,
        typer.Option("--version", callback=_show_version, is_eager=True, help="Print the version."),
    ] = False,
) -> None:
    pass


@app.command("add-feature")
def add_feature_command(
    features: Annotated[
        str, typer.Argument(help="Comma-separated feature names, applied in order.")
    ],
    path: Annotated[str, typer.Argument(help="Package directory.")] = ".",
    data: Annotated[
        list[str] | None,
        typer.Option(
            "--data", "-d", metavar="KEY=VALUE", help="Answer a template question; repeatable."
        ),
    ] = None,
    ref: Annotated[
        str | None, typer.Option(help="Git ref of the template (default: its latest release).")
    ] = None,
    template: Annotated[str, typer.Option(help="Template URL or local path.")] = TEMPLATE_URL,
    preserve_template_version: Annotated[
        bool,
        typer.Option(
            "--preserve-template-version/--no-preserve-template-version",
            help="Keep the _commit and _src_path already in .copier-answers.yml, so a later "
            "update does not skip the versions in between.",
        ),
    ] = True,
    as_json: JsonOption = False,
) -> None:
    """Apply one or more template features to an existing package."""
    if features.rstrip().endswith(","):
        # `bestie add-feature X, Y`: the shell splits on the space, so Y would
        # silently become the destination PATH
        raise typer.BadParameter(
            "must be one comma-separated argument, without spaces", param_hint="FEATURES"
        )
    names = [name for name in (part.strip() for part in features.split(",")) if name]
    if not names:
        raise typer.BadParameter("no feature names given", param_hint="FEATURES")

    values = {}
    for pair in data or []:
        key, separator, value = pair.partition("=")
        if not key or not separator:
            raise typer.BadParameter(f"expected KEY=VALUE, got {pair!r}", param_hint="--data")
        values[key] = value

    try:
        result = add_feature(
            names,
            path,
            values,
            ref=ref,
            template=template,
            preserve_template_version=preserve_template_version,
        )
    except BestieError as exc:
        raise _fail(exc, as_json) from exc

    if as_json:
        typer.echo(json.dumps(result))
        return
    typer.echo(f"Applied {len(result['applied'])} feature(s) to {result['dst']}:")
    for applied in result["applied"]:
        typer.echo(f"  {applied['name']}: {', '.join(applied['files'])}")
    if result["answers_file_updated"]:
        typer.echo("Updated .copier-answers.yml with the merged answers.")
    else:
        typer.echo("No .copier-answers.yml in the destination; none was created.")


@app.command("list-features")
def list_features_command(as_json: JsonOption = False) -> None:
    """List the features that add-feature can apply."""
    try:
        features = list_features()
    except BestieError as exc:
        raise _fail(exc, as_json) from exc

    if as_json:
        typer.echo(json.dumps(features))
        return
    width = max(len(feature["name"]) for feature in features)
    for feature in features:
        alias = feature.get("alias_of")
        text = f"alias of {alias}" if alias else feature["description"]
        typer.echo(f"{feature['name']:<{width}}  {text}")
