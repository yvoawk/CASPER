#!/usr/bin/env python3

# ===============================================================================================
# CASPER version v1.0.1
# Author: Yvon K. Awuklu
# Description: Python script to compute meta-events from simple events using Clingo CLI.
# ================================================================================================

import argparse
import json
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
import tempfile
import os

def compute_meta_events(base_files, meta_event, simple_events, unit):
    """Compute meta-events using Clingo CLI."""
    with tempfile.NamedTemporaryFile(mode="w+", suffix=".lp", delete=False) as temp_facts:
        facts_content = "\n".join(f"{event}." for event in simple_events)
        temp_facts.write(facts_content)
        temp_facts_path = temp_facts.name

    cmd = [
        "clingo",
        "--outf=2",
        "-c unit=" + unit,
        *base_files,
        meta_event,
        temp_facts_path
    ]

    try:
        proc = subprocess.run(cmd, check=False, capture_output=True, text=True)
        os.unlink(temp_facts_path)

        if proc.returncode not in (0, 10, 30):
            print(f"Clingo failed with return code {proc.returncode}", file=sys.stderr)
            return [], 0.0, 0.0

        output = json.loads(proc.stdout)
        witnesses = output.get("Call", [{}])[0].get("Witnesses", [])
        time_info = output.get("Time", {})
        cpu_time = time_info.get("CPU", 0.0)
        total_time = time_info.get("Total", 0.0)

        if not witnesses:
            return [], total_time, cpu_time

        return [str(sym) for sym in witnesses[0].get("Value", [])], total_time, cpu_time

    except Exception as e:
        print(f"Error while running clingo: {e}", file=sys.stderr)
        return [], 0.0, 0.0

def parse_args():
    parser = argparse.ArgumentParser(description="Compute meta-events from simple events using Clingo CLI.")
    parser.add_argument("base_files", help="Space-separated list of base .lp files")
    parser.add_argument("meta_event", help="Path to meta_event.lp")
    parser.add_argument("repair_json", help="Input JSON file with repaired simple events")
    parser.add_argument("--threads", type=int, default=1, help="Number of parallel threads")
    parser.add_argument("--unit", default="seconds", help="Time unit (default: seconds)")
    return parser.parse_args()

def main():
    args = parse_args()
    base_files = args.base_files.split()
    meta_event = args.meta_event
    repair_file = args.repair_json
    unit = args.unit if hasattr(args, 'unit') else "seconds"
    thread_count = args.threads

    with open(repair_file) as f:
        data = json.load(f)

    witnesses = data["Call"][0]["Witnesses"]

    # Initialize cumulative timers
    cumulative_time = 0.0
    cumulative_cpu = 0.0

    def process_witness(witness):
        nonlocal cumulative_time, cumulative_cpu
        simple_events = witness["Value"]
        complex_result, t_total, t_cpu = compute_meta_events(base_files, meta_event, simple_events, unit)

        witness["Value"] = [str(e) for e in complex_result] if complex_result else []
        witness["Time"] += round(t_total, 3)
        cumulative_time += t_total
        cumulative_cpu += t_cpu
        return witness

    with ThreadPoolExecutor(max_workers=thread_count) as executor:
        results = list(executor.map(process_witness, witnesses))

    data["Call"][0]["Witnesses"] = results

    # Update Time field
    data["Call"][0]["Stop"] = round(cumulative_time, 3)
    data["Time"]["Total"] = round(cumulative_time, 3)
    data["Time"]["CPU"] = round(cumulative_cpu, 3)

    # Update Input field
    data["Input"] = [
        f for f in data["Input"]
        if "parameters3.lp" not in f
    ]
    data["Input"].append(meta_event)

    print(json.dumps(data, indent=2))

if __name__ == "__main__":
    main()
