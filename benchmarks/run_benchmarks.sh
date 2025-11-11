#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVER="$ROOT_DIR/execution/multishot_driver.py"
BASE_FILES=(
  "$ROOT_DIR/app/lung_cancer/domain/atemporal_facts.lp"
  "$ROOT_DIR/utils/auxiliary.lp"
  "$ROOT_DIR/app/lung_cancer/user_parameters/simple_event.lp"
)
STEP_MODULES=(
  "$ROOT_DIR/encoding/expansion.lp"
  "$ROOT_DIR/encoding/linear.lp"
)
CHECK_MODULES=("$ROOT_DIR/app/lung_cancer/user_parameters/meta_event.lp")

run_case() {
  local name="$1"
  local facts="$ROOT_DIR/benchmarks/$name/facts.lp"
  local output="$ROOT_DIR/benchmarks/$name/results.json"
  python "$DRIVER" \
    --facts "$facts" \
    --base "${BASE_FILES[@]}" \
    --step "$facts" "${STEP_MODULES[@]}" \
    --check "${CHECK_MODULES[@]}" \
    --output "$output"
  echo "Saved $name results to $output"
}

run_case dense
run_case sparse
