#!/usr/bin/env python3
# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Python script to wrap atemporal facts with #program base directive.
# ===============================================================================================

from __future__ import annotations

import argparse
from pathlib import Path
import sys
from typing import List


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Ensure atemporal facts are wrapped with #program base."
    )
    parser.add_argument("input_file", help="Path to raw atemporal facts.")
    parser.add_argument("output_file", help="Destination for generated file.")
    return parser.parse_args()


def read_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8").splitlines(keepends=True)


def has_header(lines: List[str]) -> bool:
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("%"):
            continue
        return stripped.startswith("#program")
    return False


def write_output(path: Path | None, lines: List[str]) -> None:
    target = sys.stdout if path is None else path.open("w", encoding="utf-8")
    with target as outfile:
        outfile.write("#program base.\n\n")
        outfile.writelines(lines)


def main() -> None:
    args = parse_arguments()
    input_path = Path(args.input_file)
    if not input_path.exists():
        raise FileNotFoundError(f"Input file '{input_path}' does not exist.")

    lines = read_lines(input_path)
    if has_header(lines):
        contents = "".join(lines)
        if args.output_file == "-":
            sys.stdout.write(contents)
        else:
            Path(args.output_file).write_text(contents, encoding="utf-8")
        return

    target_path = None if args.output_file == "-" else Path(args.output_file)
    write_output(target_path, lines)


if __name__ == "__main__":
    main()
