"""The `bestie` CLI: argument parsing and printing over the bestie_template API."""

from __future__ import annotations

import argparse
import json
import sys
from importlib.metadata import version

from . import TEMPLATE_URL, BestieError, add_feature, list_features


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="bestie",
        description="Add BestieTemplate features to Julia packages, without installing Julia.",
    )
    parser.add_argument("--version", action="version", version=version("bestie-template"))
    commands = parser.add_subparsers(dest="command", required=True)

    common = argparse.ArgumentParser(add_help=False)
    common.add_argument(
        "--json", action="store_true", dest="as_json", help="Emit machine-readable JSON."
    )

    add = commands.add_parser(
        "add-feature", parents=[common], help="Apply template features to an existing package."
    )
    add.add_argument("features", help="Comma-separated feature names, applied in order.")
    add.add_argument("path", nargs="?", default=".", help="Package directory (default: .).")
    add.add_argument(
        "-d",
        "--data",
        action="append",
        default=[],
        metavar="KEY=VALUE",
        help="Answer a template question; repeatable.",
    )
    add.add_argument("--ref", help="Git ref of the template (default: its latest release).")
    add.add_argument("--template", default=TEMPLATE_URL, help="Template URL or local path.")

    commands.add_parser(
        "list-features", parents=[common], help="List the features that add-feature can apply."
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "list-features":
            _print_features(list_features(), args.as_json)
        else:
            _add_feature(parser, args)
    except BestieError as exc:
        if args.as_json:
            print(json.dumps({"error": str(exc)}))
        else:
            print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


def _add_feature(parser: argparse.ArgumentParser, args: argparse.Namespace) -> None:
    if args.features.rstrip().endswith(","):
        # `bestie add-feature X, Y`: the shell splits on the space, so Y would
        # silently become the destination PATH
        parser.error("FEATURES must be one comma-separated argument, without spaces")
    names = [name for name in (part.strip() for part in args.features.split(",")) if name]
    if not names:
        parser.error("no feature names given")

    data = {}
    for pair in args.data:
        key, separator, value = pair.partition("=")
        if not key or not separator:
            parser.error(f"--data expects KEY=VALUE, got {pair!r}")
        data[key] = value

    result = add_feature(names, args.path, data, ref=args.ref, template=args.template)
    if args.as_json:
        print(json.dumps(result))
        return
    print(f"Applied {len(result['applied'])} feature(s) to {result['dst']}:")
    for applied in result["applied"]:
        print(f"  {applied['name']}: {', '.join(applied['files'])}")
    if result["answers_file_updated"]:
        print("Updated .copier-answers.yml with the merged answers.")
    else:
        print("No .copier-answers.yml in the destination; none was created.")


def _print_features(features: list[dict], as_json: bool) -> None:
    if as_json:
        print(json.dumps(features))
        return
    width = max(len(feature["name"]) for feature in features)
    for feature in features:
        alias = feature.get("alias_of")
        text = f"alias of {alias}" if alias else feature["description"]
        print(f"{feature['name']:<{width}}  {text}")
