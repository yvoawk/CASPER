#!/bin/bash

# ==============================================================================
# CASPER Workflow Runner Script (v1.0.1)
# Author: Yvon K. Awuklu
# Description: Executes Clinical ASP-based Event Recognition System (one-shot mode)
# ==============================================================================

trap 'echo "⚠️  Interrupted, cleaning up..."; exit 1' INT TERM

VERSION="1.0.1"
REPAIR="no"
THREADS=1
VERBOSE="no"
TIMELINE="naive"
WINDOW=""
WIN_START=""
WIN_END=""
UNIT="seconds"
PYTHON_SCRIPT="./utils/process_answers.py"
FILTER_SCRIPT="./utils/filter_fact.py"
FACT_GENERATOR_SCRIPT="./utils/generate_step_program.py"
SIMPLE_EVENT_GENERATOR="./utils/generate_simple_events.py"
META_EVENT_GENERATOR="./utils/generate_meta_events.py"
ATEMPORAL_GENERATOR="./utils/generate_atemporal_facts.py"

show_help() {
  echo "CASPER version $VERSION"
  echo "Usage: $0 --app=APP_NAME [OPTIONS]"
  echo
  echo "Required:"
  echo "  --app=APP_NAME           Name of the app (must match a folder in ./app/ and not contain spaces)"
  echo
  echo "Options:"
  echo "  --repair=(yes|no)        Enable or disable repair mode (default: no)"
  echo "  --timeline=MODE          Timeline mode (naive|preferred|cautious) (default: naive)"
  echo "                           Note: 'preferred' & 'cautious' can only be used with --repair=yes"
  echo "  --thread-N=N             Number of parallel threads (default: 1)"
  echo "  --window=start-end       Time window for event recognition (format: start-end, both numeric)"
  echo "                           Example: --window=1609459200-1609545600"
  echo "                           Note: start must be less than end"
  echo "  --unit=seconds           Units of the time used (default: seconds)"
  echo "                           Other options: minutes, hours, days"
  echo "  --verbose                Print configuration before execution"
  echo "  --help                   Show helper message"
  echo "  --version                Show CASPER version information"
}

if [[ $# -eq 0 ]]; then
  show_help
  exit 1
fi

# Argument parsing
while [[ $# -gt 0 ]]; do
  case $1 in
  --repair=*)
    REPAIR="${1#*=}"
    ;;
  --app=*)
    APP="${1#*=}"
    ;;
  --thread-N=*)
    THREADS="${1#*=}"
    ;;
  --verbose)
    VERBOSE="yes"
    ;;
  --timeline=*)
    TIMELINE="${1#*=}"
    ;;
  --unit=*)
    UNIT="${1#*=}"
    ;;
  --help)
    show_help
    exit 0
    ;;
  --version)
    echo "CASPER version $VERSION"
    echo
    echo "Copyright (c) 2025 Yvon K. Awuklu"
    echo
    echo "Licensed under the MIT License <https://opensource.org/licenses/MIT>."
    exit 0
    ;;
  --window=*)
    WINDOW="${1#*=}"
    ;;
  *)
    echo "❌ Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
  shift
done

# Validation
[[ "$REPAIR" =~ ^(yes|no)$ ]] || {
  echo "❌ Invalid --repair value: $REPAIR (must be yes or no)"
  exit 1
}

[[ "$THREADS" =~ ^[1-9][0-9]*$ ]] || {
  echo "❌ Invalid --thread-N value: $THREADS (must be integer >= 1)"
  exit 1
}

[[ -z "$APP" ]] && {
  echo "❌ Missing required argument: --app=APP_NAME"
  exit 1
}

if [[ -n "$WINDOW" ]]; then
  if [[ "$WINDOW" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    WIN_START="${BASH_REMATCH[1]}"
    WIN_END="${BASH_REMATCH[2]}"
    if ((WIN_END <= WIN_START)); then
      echo "❌ Invalid --WINDOW value: End time must be greater than start time."
      exit 1
    fi
  else
    echo "❌ Invalid --WINDOW format. Expected --WINDOW=start-end (both numeric)."
    exit 1
  fi
fi

[[ "$UNIT" =~ ^(seconds|minutes|hours|days)$ ]] || {
  echo "❌ Invalid --units value: $UNIT (must be seconds, minutes, hours, or days)"
  exit 1
}

if [[ "$REPAIR" == "yes" && "$TIMELINE" != "preferred" && "$TIMELINE" != "cautious" ]]; then
  TIMELINE="consistent"
  fi

APP_DIR="./app/${APP}"
[[ -d "$APP_DIR" ]] || {
  echo "❌ App not found: $APP"
  exit 1
}

RAW_FACTS="$APP_DIR/facts/raw_facts.lp"
FACTS_INPUT="$APP_DIR/facts/facts.lp"
FACTS_SOLVER="$APP_DIR/facts/facts.solver.lp"
FILTERED_RAW_FACTS="$APP_DIR/facts/raw_facts.filtered.lp"
STEP_ACT_FILE="$APP_DIR/facts/step_activation.lp"

RAW_SIMPLE="$APP_DIR/user_parameters/raw_simple_event.lp"
SIMPLE_INPUT="$APP_DIR/user_parameters/simple_event.lp"
SIMPLE_SOLVER="$APP_DIR/user_parameters/simple_event.solver.lp"

RAW_META="$APP_DIR/user_parameters/raw_meta_event.lp"
META_INPUT="$APP_DIR/user_parameters/meta_event.lp"
META_SOLVER="$APP_DIR/user_parameters/meta_event.solver.lp"

RAW_ATEMPORAL="$APP_DIR/domain/raw_atemporal_facts.lp"
ATEMPORAL_INPUT="$APP_DIR/domain/atemporal_facts.lp"
ATEMPORAL_SOLVER="$APP_DIR/domain/atemporal_facts.solver.lp"

STEP_ACTIVATION_SCRIPT="./utils/generate_step_activation.py"

has_step_sections() {
  local file="$1"
  [[ -f "$file" ]] && grep -q "^#program step(" "$file"
}

prepare_component() {
  local raw="$1"
  local ready="$2"
  local generator="$3"
  local output="$4"
  local label="$5"

  local source="$ready"
  local used_raw="no"
  if [[ -f "$raw" ]]; then
    source="$raw"
    used_raw="yes"
  fi

  if [[ ! -f "$source" ]]; then
    echo "❌ Missing $label file: $source"
    exit 1
  fi

  local needs_conversion="$used_raw"
  if [[ "$needs_conversion" != "yes" && -n "$generator" ]]; then
    if ! has_step_sections "$source"; then
      needs_conversion="yes"
    fi
  fi

  if [[ "$needs_conversion" == "yes" ]]; then
    python "$generator" "$source" "$output"
    if [[ $? -ne 0 ]]; then
      echo "❌ Error: Failed to generate $output from $source."
      exit 1
    fi
    printf '%s\n' "$output"
  else
    printf '%s\n' "$source"
  fi
}

FACTS_SOURCE="$FACTS_INPUT"
[[ -f "$RAW_FACTS" ]] && FACTS_SOURCE="$RAW_FACTS"
FACTS_RAW_USED="$FACTS_SOURCE"

if [[ "$WINDOW" ]]; then
  if [[ ! -f "$RAW_FACTS" ]]; then
    echo "❌ Applying a time window requires $RAW_FACTS."
    exit 1
  fi
  echo "🔍 Applying time window: $WINDOW"
  python "$FILTER_SCRIPT" "$RAW_FACTS" "$FILTERED_RAW_FACTS" "$WIN_START" "$WIN_END"
  if [[ $? -ne 0 ]]; then
    echo "❌ Error: Failed to filter facts with time window."
    exit 1
  fi
  FACTS_RAW_USED="$FILTERED_RAW_FACTS"
fi

if has_step_sections "$FACTS_RAW_USED"; then
  FACTS_FOR_RUN="$FACTS_RAW_USED"
else
  python "$FACT_GENERATOR_SCRIPT" "$FACTS_RAW_USED" "$FACTS_SOLVER"
  if [[ $? -ne 0 ]]; then
    echo "❌ Error: Failed to generate $FACTS_SOLVER from $FACTS_RAW_USED."
    exit 1
  fi
  FACTS_FOR_RUN="$FACTS_SOLVER"
fi

python "$STEP_ACTIVATION_SCRIPT" "$FACTS_FOR_RUN" "$STEP_ACT_FILE"
if [[ $? -ne 0 ]]; then
  echo "❌ Error: Failed to generate step activation file."
  exit 1
fi

SIMPLE_EVENT="$(prepare_component "$RAW_SIMPLE" "$SIMPLE_INPUT" "$SIMPLE_EVENT_GENERATOR" "$SIMPLE_SOLVER" "simple event")"
ATEMPORAL_FACTS="$(prepare_component "$RAW_ATEMPORAL" "$ATEMPORAL_INPUT" "$ATEMPORAL_GENERATOR" "$ATEMPORAL_SOLVER" "atemporal facts")"
META_EVENT=""
if [[ -f "$RAW_META" || -f "$META_INPUT" ]]; then
  META_EVENT="$(prepare_component "$RAW_META" "$META_INPUT" "$META_EVENT_GENERATOR" "$META_SOLVER" "meta event")"
fi

# Output setup
RESULTS_DIR="./results/${APP}"
mkdir -p "$RESULTS_DIR"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
#OUTPUT="$RESULTS_DIR/results_${DATE}.json"
TEMP_JSON="./temp_stage1_${DATE}.json"

case "$TIMELINE" in
naive)
  MODE="auto"
  mkdir -p "$RESULTS_DIR/naive"
  OUTPUT="$RESULTS_DIR/naive/results_${DATE}.json"
  ;;
cautious)
  if [[ "$REPAIR" != "yes" ]]; then
    echo "❌ --timeline=cautious can only be used when --repair=yes"
    exit 1
  fi
  MODE="cautious"
  mkdir -p "$RESULTS_DIR/cautious"
  OUTPUT="$RESULTS_DIR/cautious/results_${DATE}.json"
  ;;
preferred)
  if [[ "$REPAIR" != "yes" ]]; then
    echo "❌ --timeline=preferred can only be used when --repair=yes"
    exit 1
  fi
  MODE="auto"
  mkdir -p "$RESULTS_DIR/preferred"
  OUTPUT="$RESULTS_DIR/preferred/results_${DATE}.json"
  ;;
consistent)
  MODE="auto"
  mkdir -p "$RESULTS_DIR/consistent" 
  OUTPUT="$RESULTS_DIR/consistent/results_${DATE}.json"
  ;;
*)
  echo "❌ Invalid --timeline value: $TIMELINE (must be naive, preferred or cautious)"
  exit 1
  ;;
esac


echo "📦 Running CASPER v$VERSION"

# Verbose config
[[ "$VERBOSE" == "yes" ]] && {
  echo "======================= Configuration ======================="
  echo "App:            $APP"
  echo "Repair mode:    $REPAIR"
  echo "Threads:        $THREADS"
  echo "Timeline:       $TIMELINE"
  echo "Unit:           $UNIT"
  [[ -n "$WINDOW" ]] && echo "Time window:    $WINDOW"
  echo "Simple event:   found"
  if [[ -n "$META_EVENT" && -f "$META_EVENT" ]]; then
    echo "Meta-event:     found"
  else
    echo "Meta-event:  not found"
  fi
  echo "Timestamp:      $(date)"
  echo "============================================================="
}

BASE_OPTS="--mode=clingo --opt-mode=optN --models 0 --parallel-mode=$THREADS --outf=2 --stats=2 --enum-mode=$MODE -c unit=$UNIT"

[[ -f "$SIMPLE_EVENT" ]] || {
  echo "❌ Missing simple event file: $SIMPLE_EVENT"
  exit 1
}

[[ -f "$ATEMPORAL_FACTS" ]] || {
  echo "❌ Missing atemporal facts file: $ATEMPORAL_FACTS"
  exit 1
}

[[ -f "$STEP_ACT_FILE" ]] || {
  echo "❌ Missing step activation file: $STEP_ACT_FILE"
  exit 1
}

BASE_FILES="$FACTS_FOR_RUN ./encoding/expansion.lp ./encoding/linear.lp $ATEMPORAL_FACTS ./utils/auxiliary.lp $STEP_ACT_FILE"
BASE_FILES_2="$FACTS_FOR_RUN $SIMPLE_EVENT $ATEMPORAL_FACTS ./utils/auxiliary.lp $STEP_ACT_FILE ./execution/parameters1.lp"

if [[ "$REPAIR" == "no" ]]; then
  PARAM_FILE="./execution/parameters2.lp"
  if [[ -n "$META_EVENT" && -f "$META_EVENT" ]]; then
    PARAM_FILE="./execution/parameters1.lp"
  fi

  if [[ -n "$META_EVENT" && -f "$META_EVENT" ]]; then
    echo "⚙️  Processing both simple and meta- events..."
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" "$META_EVENT" "$PARAM_FILE" >"$OUTPUT"
  else
    echo "⚙️  Processing only simple events (no meta_event.lp found)..."
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" "$PARAM_FILE" >"$OUTPUT"
  fi

else
  echo "🔧 Stage 1: Simple events with repair..."
  if [[ "$TIMELINE" == "preferred" ]]; then
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" ./encoding/repair.lp ./execution/parameters3.lp ./encoding/preference.lp >"$TEMP_JSON"
  else
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" ./encoding/repair.lp ./execution/parameters3.lp >"$TEMP_JSON"
  fi
  EXIT_CODE=$?

  if [[ $EXIT_CODE -ne 0 && $EXIT_CODE -ne 10 && $EXIT_CODE -ne 30 ]]; then
    echo "❌ Error: Stage 1 failed with exit code $EXIT_CODE"
    rm -f "$TEMP_JSON"
    exit 1
  fi

  if [[ -n "$META_EVENT" && -f "$META_EVENT" ]]; then
    echo "🔍 Stage 2: Computing meta-events from repaired simple events..."
    python "$PYTHON_SCRIPT" "$BASE_FILES_2" "$META_EVENT" "$TEMP_JSON" --unit "$UNIT" --threads "$THREADS" >"$OUTPUT"
    rm -f "$TEMP_JSON"
  else
    echo "ℹ️  No complex_event.lp found, skipping Stage 2"
    mv "$TEMP_JSON" "$OUTPUT"
  fi
fi

echo "✅ Results saved to $OUTPUT"
