#!/bin/bash
# Basic guard-rail script for CASPER encodings.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

# 1. Ensure #show directives are scoped to final projections.
SHOW_LINES=$(rg -n "#show" "$ROOT_DIR" --glob "*.lp" || true)
if [[ -n "$SHOW_LINES" ]]; then
  BAD_SHOW=$(printf "%s\n" "$SHOW_LINES" | grep -v -E "#show (event/6|event/5|event\\(ID|rep_event)" || true)
  if [[ -n "$BAD_SHOW" ]]; then
    printf "%s\n" "$BAD_SHOW" >&2
    echo "Unexpected #show directive detected. Limit projections to event/5-6." >&2
    FAIL=1
  fi
fi

# 2. Run dense benchmark to detect unsafe variables/joins at grounding time.
if ! python "$ROOT_DIR/execution/multishot_driver.py" \
    --facts "$ROOT_DIR/benchmarks/dense/facts.lp" \
    --base "$ROOT_DIR/app/lung_cancer/domain/atemporal_facts.lp" "$ROOT_DIR/utils/auxiliary.lp" "$ROOT_DIR/app/lung_cancer/user_parameters/simple_event.lp" \
    --step "$ROOT_DIR/benchmarks/dense/facts.lp" "$ROOT_DIR/encoding/expansion.lp" "$ROOT_DIR/encoding/linear.lp" \
    --check "$ROOT_DIR/app/lung_cancer/user_parameters/meta_event.lp" \
    --clingo-args --warn=global-variable --warn=domain-error --warn=atom-undefined --models=0 >/dev/null; then
  echo "Grounding failed. Inspect warnings above for unsafe variables or joins." >&2
  FAIL=1
fi

if (( FAIL )); then
  exit 1
fi

echo "Pre-commit checks passed."
