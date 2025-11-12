#!/usr/bin/env python3
"""
Generate a helper file that activates all step/check externals for one-shot runs.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import List


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create activation facts for every #program step(<label>)."
    )
    parser.add_argument("facts_file", help="Facts file containing #program step(...) directives.")
    parser.add_argument("output_file", help="Destination file for activation facts.")
    return parser.parse_args()


def collect_steps(facts_path: Path) -> List[str]:
    pattern = re.compile(r"#program\s+step\(([^)]+)\)\.")
    steps: List[str] = []
    with facts_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            match = pattern.match(line.strip())
            if match:
                steps.append(match.group(1))
    unique = []
    for step in steps:
        if step not in unique:
            unique.append(step)
    return unique


def write_activation(path: Path, steps: List[str]) -> None:
    with path.open("w", encoding="utf-8") as outfile:
        outfile.write("#program base.\n\n")
        for step in steps:
            outfile.write(f"use_temporal_index({step}).\n")
            outfile.write(f"use_simple_events({step}).\n")
            outfile.write(f"use_expansion({step}).\n")
            outfile.write(f"use_linear({step}).\n")
            outfile.write(f"use_meta_events({step}).\n")
            outfile.write(f"use_repair({step}).\n")
            outfile.write(f"use_preference({step}).\n\n")


def main() -> None:
    args = parse_arguments()
    facts_path = Path(args.facts_file)
    if not facts_path.exists():
        raise FileNotFoundError(f"Facts file '{facts_path}' does not exist.")
    steps = collect_steps(facts_path)
    if not steps:
        raise RuntimeError(f"No #program step(...) directives found in '{facts_path}'.")
    write_activation(Path(args.output_file), steps)


if __name__ == "__main__":
    main()
