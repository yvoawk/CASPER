#!/usr/bin/env python3

# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Python script to wrap plain observation facts into the #program step/step_time
# structure expected by the temporal ASP encodings.
# ===============================================================================================

from __future__ import annotations

import argparse
from collections import OrderedDict
from pathlib import Path
from typing import Dict, List, Tuple


def strip_inline_comment(line: str) -> str:
    """
    Remove ASP-style inline comments (starting with %) from a line.

    Returns the fact portion trimmed from leading/trailing whitespace.
    """
    return line.split("%", 1)[0].strip()


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Group obs(Patient, …, Timestamp) facts by timestamp and emit "
            "#program step blocks understood by the CASPER encodings."
        )
    )
    parser.add_argument(
        "input_file",
        help="Path to the user-provided facts file containing obs.",
    )
    parser.add_argument(
        "output_file",
        help="Destination path for the generated facts with #program directives.",
    )
    parser.add_argument(
        "--preserve-order",
        action="store_true",
        help="Keep timestamps in the order they appear instead of sorting them numerically.",
    )
    return parser.parse_args()


def extract_timestamp(fact_text: str, line_no: int) -> Tuple[int, str]:
    if not fact_text.startswith("obs(") or not fact_text.endswith(")."):
        raise ValueError(f"Line {line_no}: Expected obs(...) fact, got '{fact_text}'.")

    payload = fact_text[len("obs(") : -2]
    parts = [part.strip() for part in payload.split(",")]
    if not parts:
        raise ValueError(f"Line {line_no}: Missing arguments in '{fact_text}'.")
    timestamp_text = parts[-1]
    try:
        timestamp_value = int(timestamp_text)
    except ValueError as exc:
        raise ValueError(
            f"Line {line_no}: Timestamp '{timestamp_text}' is not an integer."
        ) from exc
    return timestamp_value, timestamp_text


def group_obs_by_timestamp(
    text: List[str], preserve_order: bool
) -> Dict[str, List[str]]:
    buckets: "OrderedDict[str, List[str]]" = OrderedDict()
    order_helper: Dict[str, int] = {}

    for idx, line in enumerate(text, start=1):
        fact_segment = strip_inline_comment(line)
        if not fact_segment or not fact_segment.startswith("obs("):
            continue
        ts_value, ts_text = extract_timestamp(fact_segment, idx)
        buckets.setdefault(ts_text, []).append(
            line if line.endswith("\n") else f"{line}\n"
        )
        order_helper.setdefault(ts_text, ts_value)

    if preserve_order:
        return buckets

    sorted_buckets = OrderedDict()
    for ts in sorted(order_helper, key=lambda key: order_helper[key]):
        sorted_buckets[ts] = buckets[ts]
    return sorted_buckets


def write_program(
    output_path: Path, grouped_obs: Dict[str, List[str]], header_lines: List[str]
) -> None:
    with output_path.open("w", encoding="utf-8") as outfile:
        for line in header_lines:
            outfile.write(line if line.endswith("\n") else f"{line}\n")

        if header_lines and grouped_obs:
            outfile.write("\n")

        for ts, obs_lines in grouped_obs.items():
            program_label = f"t{ts}"
            outfile.write(f"#program step({program_label}).\n")
            outfile.write(f"step_time({ts}, {ts}).\n")
            for fact_line in obs_lines:
                outfile.write(fact_line)
            outfile.write("\n")


def main() -> None:
    args = parse_arguments()
    input_path = Path(args.input_file)
    output_path = Path(args.output_file)

    if not input_path.exists():
        raise FileNotFoundError(f"Input file '{input_path}' does not exist.")

    lines = input_path.read_text(encoding="utf-8").splitlines(True)
    grouped_obs = group_obs_by_timestamp(lines, args.preserve_order)

    header_lines = [
        line if line.endswith("\n") else f"{line}\n"
        for line in lines
        if not strip_inline_comment(line).startswith("obs(")
    ]
    write_program(output_path, grouped_obs, header_lines)


if __name__ == "__main__":
    main()
