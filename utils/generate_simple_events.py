#!/usr/bin/env python3

# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Python script to wrap simple-event rules with #program base/step directives.
# ===============================================================================================
"""
Convert user provided simple-event rules (without multi-shot boilerplate)
into the solver-ready structure (#program base/step) required by CASPER.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys
from textwrap import dedent
from typing import List


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Wrap raw simple-event rules with #program base/step blocks and "
            "inject use_simple_events/time_scope guards automatically."
        )
    )
    parser.add_argument("input_file", help="Path to raw simple-event rules.")
    parser.add_argument("output_file", help="Destination for generated file.")
    return parser.parse_args()


def split_arguments(arg_text: str) -> List[str]:
    args: List[str] = []
    depth = 0
    current = []
    for char in arg_text:
        if char == "," and depth == 0:
            args.append("".join(current).strip())
            current = []
            continue
        current.append(char)
        if char in "([{":
            depth += 1
        elif char in ")]}":
            depth = max(depth - 1, 0)
    if current:
        args.append("".join(current).strip())
    return args


def detect_time_variable(head: str) -> str | None:
    head = head.strip()
    if not head or head == ":-":
        return None
    if "(" not in head or not head.endswith(")"):
        return None
    name, arg_text = head.split("(", 1)
    arg_text = arg_text.rsplit(")", 1)[0]
    args = split_arguments(arg_text)
    if len(args) < 2:
        return None
    candidate = args[-2].strip()
    if candidate and candidate[0].isupper():
        return candidate
    return None


def indent_block(text: str, prefix: str = "    ") -> str:
    if not text:
        return ""
    lines = dedent(text).splitlines()
    return "\n".join(
        prefix + line.strip() if line.strip() else "" for line in lines
    )


def separate_prefix(statement: str) -> tuple[str, str]:
    prefix_lines: List[str] = []
    core_lines: List[str] = []
    found_content = False
    for line in statement.splitlines(keepends=True):
        stripped = line.strip()
        if not found_content and (not stripped or stripped.startswith("%")):
            prefix_lines.append(line)
            continue
        found_content = True
        core_lines.append(line)
    return "".join(prefix_lines), "".join(core_lines)


def add_guards(statement: str) -> str:
    raw = statement.strip("\n")
    if not raw:
        return raw

    prefix, core = separate_prefix(raw)
    if not core.strip():
        return raw

    raw = core
    if ":-" in raw:
        head_raw, body_raw = raw.split(":-", 1)
    else:
        transformed = raw if raw.endswith(".") else f"{raw}."
        return f"{prefix}{transformed}" if prefix else transformed

    body_clean = body_raw.strip()
    if body_clean.endswith("."):
        body_clean = body_clean[:-1]
    body_clean = body_clean.rstrip()

    head = head_raw.strip()
    guards = ["use_simple_events(t)"]
    time_var = detect_time_variable(head)
    if time_var:
        guards.append(f"time_scope(t, {time_var})")

    guard_block = ",\n".join(f"    {guard}" for guard in guards)
    body_block = indent_block(body_clean)

    if guard_block and body_block:
        combined = f"{guard_block},\n{body_block}"
    elif guard_block:
        combined = guard_block
    else:
        combined = body_block

    head_prefix = head if head else ":-"
    transformed_core = f"{head_prefix} :-\n{combined}."
    return f"{prefix}{transformed_core}" if prefix else transformed_core


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


def build_output(base_statements: List[str], dynamic_statements: List[str]) -> str:
    base_section = ["#program base.\n\n"]
    base_section.extend(base_statements)
    if base_statements and not base_statements[-1].endswith("\n\n"):
        base_section.append("\n")

    step_section = ["#program step(t).\n", "#external use_simple_events(t).\n\n"]
    for stmt in dynamic_statements:
        transformed = add_guards(stmt)
        step_section.append(f"{transformed}\n\n")

    return "".join(base_section + step_section).rstrip() + "\n"


def main() -> None:
    args = parse_arguments()
    raw_path = Path(args.input_file)
    if not raw_path.exists():
        raise FileNotFoundError(f"Input file '{raw_path}' does not exist.")

    contents = raw_path.read_text(encoding="utf-8")
    statements = split_statements(contents)
    base_statements, dynamic_statements = classify_statements(statements)
    output_text = build_output(base_statements, dynamic_statements)
    if args.output_file == "-":
        sys.stdout.write(output_text)
    else:
        out_path = Path(args.output_file)
        out_path.write_text(output_text, encoding="utf-8")


if __name__ == "__main__":
    main()
