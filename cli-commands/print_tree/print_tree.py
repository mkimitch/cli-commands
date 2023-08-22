#!/usr/bin/env python
"""
This module defines a function to print a directory tree with options
to avoid/omit certain directories and file extensions.
"""
import os
import argparse
import json


def print_tree(
    directory,
    prefix="",
    avoid=None,
    omit_extensions=None,
    only_extensions=None,
    file=None,
    is_root=True,
):
    if avoid is None:
        avoid = []

    entries = sorted(os.listdir(directory))
    directories = [
        e
        for e in entries
        if os.path.isdir(os.path.join(directory, e)) and e not in avoid
    ]
    files = [e for e in entries if os.path.isfile(os.path.join(directory, e))]

    if omit_extensions:
        files = [f for f in files if os.path.splitext(f)[1][1:] not in omit_extensions]
    if only_extensions:
        files = [f for f in files if os.path.splitext(f)[1][1:] in only_extensions]

    if only_extensions:
        directories = [
            d
            for d in directories
            if any(
                os.path.splitext(f)[1][1:] in only_extensions
                for _, _, files in os.walk(os.path.join(directory, d))
                for f in files
            )
        ]

    all_items = len(directories) + len(files)
    current_item = 0

    if is_root:
        print(directory, file=file)
        prefix = "   "

    for entry_name in directories:
        entry = os.path.join(directory, entry_name)
        current_item += 1
        is_last_dir = current_item == all_items

        new_prefix = prefix + ("   " if is_last_dir else " │   ")
        line_prefix = prefix + (" └─ " if is_last_dir else " ├─ ")
        print(line_prefix + entry_name, file=file)

        print_tree(
            entry,
            new_prefix,
            avoid,
            omit_extensions,
            only_extensions,
            file,
            is_root=False,
        )

    for entry_name in files:
        current_item += 1
        is_last_entry = current_item == all_items

        print(prefix + (" └─ " if is_last_entry else " ├─ ") + entry_name, file=file)


def main():
    """
    Command-line interface for the print_tree function.
    """
    config_path = "print_tree_config.json"

    try:
        with open(config_path, "r", encoding="utf-8") as config_file:
            config = json.load(config_file)
            default_avoid = config.get("avoid", [])
            default_omit_extensions = config.get("omit_extensions", [])
    except FileNotFoundError:
        print(
            f"Configuration file not found at {config_path}. Use --help for instructions."
        )
        default_avoid = []
        default_omit_extensions = []
    except json.JSONDecodeError:
        print(
            f"Malformed configuration file at {config_path}. Use --help for instructions."
        )
        default_avoid = []
        default_omit_extensions = []

    parser = argparse.ArgumentParser(description="Print a directory tree")
    parser.add_argument("directory", help="The root directory")
    parser.add_argument(
        "--only",
        nargs="*",
        help=(
            "Only include files with specific extensions without leading dot. "
            "Example: --only py txt"
        ),
    )
    parser.add_argument(
        "--avoid",
        nargs="*",
        default=default_avoid,
        help="Additional directories to avoid. Example: --avoid .git .vscode",
    )
    parser.add_argument(
        "--omit",
        nargs="*",
        default=default_omit_extensions,
        help="Additional file extensions to omit without leading dot. Example: --omit log tmp",
    )

    parser.add_argument(
        "--output", help="Output file path. Example: --output output.txt"
    )

    args = parser.parse_args()
    output_path = os.path.expanduser(args.output) if args.output else None

    # Combine default avoid list with additional values from command line
    combined_avoid = default_avoid + (args.avoid or [])

    # Combine default omit extensions list with additional values from command line
    combined_omit_extensions = default_omit_extensions + (args.omit or [])

    with open(output_path, "w", encoding="utf-8") if output_path else None as file:
        print_tree(
            args.directory,
            avoid=combined_avoid,
            omit_extensions=combined_omit_extensions,
            only_extensions=args.only,  # Change this line
            file=file,
        )


if __name__ == "__main__":
    main()
