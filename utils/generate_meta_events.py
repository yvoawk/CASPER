#!/usr/bin/env python3
# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Python script to wrap meta-event rules with the check(t) subprogram.
# ===============================================================================================

"""
Convert user defined meta-event rules into the solver-ready format by adding
#program directives and guarding rules with use_meta_events/1.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys
from textwrap import dedent
from typing import List


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Wrap raw meta-event rules with the check(t) subprogram."
    )
    parser.add_argument("input_file", help="Path to raw meta-event rules.")
    parser.add_argument("output_file", help="Destination for generated file.")
    return parser.parse_args()


def indent_block(text: str, prefix: str = "    ") -> str:
    if not text:
        return ""
    lines = dedent(text).splitlines()
    return "\n".join(
        prefix + line.strip() if line.strip() else "" for line in lines
    )


def split_statements(contents: str) -> List[str]:
    statements: List[str] = []
    buffer: List[str] = []
    for line in contents.splitlines(keepends=True):
        buffer.append(line)
        stripped = line.strip()
        if stripped.startswith("#program") or stripped.startswith("#external"):
            continue
        if stripped.endswith(".") and not stripped.startswith("%"):
            statements.append("".join(buffer))
            buffer = []
    if buffer:
        statements.append("".join(buffer))
    return statements


def leading_content(stmt: str) -> str:
    for line in stmt.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("%"):
            continue
        return stripped
    return ""


def classify_statements(statements: List[str]) -> tuple[List[str], List[str]]:
    base: List[str] = []
    dynamic: List[str] = []
    for stmt in statements:
        stripped = stmt.strip()
        if not stripped:
            continue
        if stripped.startswith("#program") or stripped.startswith("#external"):
            continue
        content = leading_content(stmt)
        if not content:
            base.append(stmt if stmt.endswith("\n") else f"{stmt}\n")
            continue
        if content.startswith("%"):
            base.append(stmt if stmt.endswith("\n") else f"{stmt}\n")
            continue
        if ":-" in content:
            dynamic.append(stmt)
        else:
            if stripped.endswith("."):
                base.append(stmt if stmt.endswith("\n") else f"{stmt}\n")
            else:
                base.append(f"{stmt.rstrip()}\n")
    return base, dynamic


def transform_rule(statement: str) -> str:
    raw = statement.strip()
    if ":-" not in raw:
        return raw if raw.endswith(".") else f"{raw}."
    head_raw, body_raw = raw.split(":-", 1)
    body_clean = body_raw.strip()
    if body_clean.endswith("."):
        body_clean = body_clean[:-1]
    body_block = indent_block(body_clean)
    guard = "    use_meta_events(t)"
    if body_block:
        combined = f"{guard},\n{body_block}"
    else:
        combined = guard
    head = head_raw.strip() or ":-"
    return f"{head} :-\n{combined}."


def build_output(base_statements: List[str], dynamic_statements: List[str]) -> str:
    parts: List[str] = []
    parts.extend(base_statements)

    if dynamic_statements:
        parts.append("#program check(t).\n")
        parts.append("#external use_meta_events(t).\n\n")
        for stmt in dynamic_statements:
            parts.append(transform_rule(stmt))
            parts.append("\n\n")

    return "".join(parts).rstrip() + "\n"


def main() -> None:
    args = parse_arguments()
    input_path = Path(args.input_file)

    if not input_path.exists():
        raise FileNotFoundError(f"Input file '{input_path}' does not exist.")

    contents = input_path.read_text(encoding="utf-8")
    statements = split_statements(contents)
    base_statements, dynamic_statements = classify_statements(statements)
    output_text = build_output(base_statements, dynamic_statements)
    if args.output_file == "-":
        sys.stdout.write(output_text)
    else:
        output_path = Path(args.output_file)
        output_path.write_text(output_text, encoding="utf-8")


if __name__ == "__main__":
    main()
