#!/usr/bin/env python3
# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Incremental CASPER runner using clingo's multi-shot interface.
# ===============================================================================================

from __future__ import annotations

import argparse
import json
import pathlib
import time
from dataclasses import dataclass, field
from typing import Iterable, List, Sequence

from clingo import Control, Function, Model, Number

@dataclass
class StepConfig:
    value: int
    activate: Sequence[str] = field(default_factory=list)


def parse_step_order(facts_path: pathlib.Path) -> List[int]:
    steps: List[int] = []
    with facts_path.open("r", encoding="utf8") as handle:
        for line in handle:
            line = line.strip()
            if line.startswith("#program step(") and line.endswith(")."):
                param = line[len("#program step(") : -2]
                if param.isdigit():
                    steps.append(int(param))
    return steps


def activate_externals(ctrl: Control, step: StepConfig, value: bool) -> None:
    for name in step.activate:
        atom = Function(name, [Number(step.value)])
        if ctrl.symbolic_atoms.contains(atom):
            ctrl.assign_external(atom, value)


def collect_model(model: Model, storage: List[List[str]]) -> None:
    storage.append(sorted(str(sym) for sym in model.symbols(shown=True)))


def run_incremental(args: argparse.Namespace) -> None:
    base = Control(arguments=args.clingo_args)
    for file_path in args.base:
        base.load(str(file_path))
    base.ground([("base", [])])

    result_store: List[List[str]] = []
    solve_start = time.perf_counter()

    step_order = parse_step_order(args.facts)
    if not step_order:
        raise RuntimeError("No #program step(...) declarations found in facts file.")

    step_activate = [
        "use_temporal_index",
        "use_simple_events",
        "use_expansion",
        "use_linear",
    ]
    check_activate = [
        "use_meta_events",
        "use_repair",
        "use_preference",
    ]

    # Load remaining modules.
    for file_path in args.step:
        base.load(str(file_path))
    for file_path in args.check:
        base.load(str(file_path))

    for step_value in step_order:
        base.ground([("step", [Number(step_value)])])
        activate_externals(base, StepConfig(step_value, step_activate), True)

        if args.check:
            base.ground([("check", [Number(step_value)])])
            activate_externals(base, StepConfig(step_value, check_activate), True)

        base.solve(on_model=lambda m: collect_model(m, result_store))

        activate_externals(base, StepConfig(step_value, step_activate), False)
        if args.check:
            activate_externals(base, StepConfig(step_value, check_activate), False)
        base.cleanup()

    total_time = round(time.perf_counter() - solve_start, 3)

    witnesses = [
        {"Value": atoms, "Costs": [], "Time": 0.0} for atoms in result_store
    ]
    payload = {
        "Solver": "casper-multishot-driver",
        "Input": [str(args.facts), *map(str, (args.base + args.step + args.check))],
        "Call": [
            {
                "Start": 0.0,
                "Stop": total_time,
                "Witnesses": witnesses,
            }
        ],
        "Result": "SAT" if witnesses else "UNSAT",
        "Models": {"Number": len(witnesses), "More": "no"},
        "Calls": 1,
        "Time": {
            "Total": total_time,
            "Solve": total_time,
            "Model": 0.0,
            "Unsat": 0.0,
            "CPU": total_time,
        },
        "Stats": {},
    }

    serialized = json.dumps(payload, indent=2)
    if args.output:
        args.output.write_text(serialized, encoding="utf8")
    else:
        print(serialized)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--facts", type=pathlib.Path, required=True, help="Facts file with #program step sections")
    parser.add_argument("--base", type=pathlib.Path, nargs="+", required=True, help="Files to load in the base program")
    parser.add_argument("--step", type=pathlib.Path, nargs="+", required=True, help="Files contributing step(t) rules")
    parser.add_argument("--check", type=pathlib.Path, nargs="*", default=[], help="Files contributing check(t) rules")
    parser.add_argument("--output", type=pathlib.Path, help="Optional JSON output path")
    parser.add_argument("--clingo-args", nargs=argparse.REMAINDER, default=["--stats=2", "--models=0"], help="Extra arguments passed to clingo")
    return parser


def main(argv: Sequence[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)
    run_incremental(args)


if __name__ == "__main__":
    main()
