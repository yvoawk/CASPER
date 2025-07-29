#!/bin/bash

# ==============================================================================
# CASPER Workflow Runner Script (v1.0.0)
# Author: XXXX XXXXXX
# Description: Executes Clinical ASP-based Event Recognition System
# ==============================================================================

trap 'echo "⚠️  Interrupted, cleaning up..."; exit 1' INT TERM

VERSION="1.0.0"
REPAIR="no"
THREADS=1
VERBOSE="no"
TIMELINE="naïve"
WINDOW=""
WIN_START=""
WIN_END=""
PYTHON_SCRIPT="./utils/process_answers.py"
FILTER_SCRIPT="./utils/filter_fact.py"

show_help() {
  echo "CASPER version $VERSION"
  echo "Usage: $0 --app=APP_NAME [OPTIONS]"
  echo
  echo "Required:"
  echo "  --app=APP_NAME           Name of the app (must match a folder in ./app/ and not contain spaces)"
  echo
  echo "Options:"
  echo "  --repair=(yes|no)        Enable or disable repair mode (default: no)"
  echo "  --timeline=MODE          Timeline mode (naïve|preferred|cautious) (default: naïve)"
  echo "                           Note: 'preferred' & 'cautious' can only be used with --repair=yes"
  echo "  --thread-N=N             Number of parallel threads (default: 1)"
  echo "  --window=start-end       Time window for event recognition (format: start-end, both numeric)"
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

case "$TIMELINE" in
naïve)
  MODE="auto"
  ;;
cautious)
  if [[ "$REPAIR" != "yes" ]]; then
    echo "❌ --timeline=cautious can only be used when --repair=yes"
    exit 1
  fi
  MODE="cautious"
  ;;
preferred)
  if [[ "$REPAIR" != "yes" ]]; then
    echo "❌ --timeline=preferred can only be used when --repair=yes"
    exit 1
  fi
  MODE="auto"
  ;;
*)
  echo "❌ Invalid --timeline value: $TIMELINE (must be naïve, preferred or cautious)"
  exit 1
  ;;
esac

APP_DIR="./app/${APP}"
[[ -d "$APP_DIR/facts" ]] || {
  echo "❌ App not found: $APP"
  exit 1
}

SIMPLE_EVENT="$APP_DIR/user_parameters/simple_event.lp"
META_EVENT="$APP_DIR/user_parameters/meta_event.lp"

ALL_FACTS="$APP_DIR/facts/facts.lp"
FILTER_FACTS="$APP_DIR/facts/filter_facts.lp"

[[ -f "$SIMPLE_EVENT" ]] || {
  echo "❌ Missing $SIMPLE_EVENT"
  exit 1
}

# Output setup
RESULTS_DIR="./results/${APP}"
mkdir -p "$RESULTS_DIR"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT="$RESULTS_DIR/results_${DATE}.json"
TEMP_JSON="./temp_stage1_${DATE}.json"

BASE_FILES="$APP_DIR/facts/facts.lp ./encoding/expansion.lp ./encoding/linear.lp $APP_DIR/domain/atemporal_facts.lp ./utils/auxiliary.lp"
BASE_FILES_2="$APP_DIR/facts/facts.lp $APP_DIR/user_parameters/simple_event.lp $APP_DIR/domain/atemporal_facts.lp ./utils/auxiliary.lp ./execution/parameters1.lp"

echo "📦 Running CASPER v$VERSION"

# Verbose config
[[ "$VERBOSE" == "yes" ]] && {
  echo "======================= Configuration ======================="
  echo "App:            $APP"
  echo "Repair mode:    $REPAIR"
  echo "Threads:        $THREADS"
  echo "Timeline:       $TIMELINE"
  [[ -n "$WINDOW" ]] && echo "Time window:    $WINDOW"
  echo "Simple event:   found"
  [[ -f "$META_EVENT" ]] && echo "Meta-event:     found" || echo "Meta-event:  not found"
  echo "Timestamp:      $(date)"
  echo "============================================================="
}

BASE_OPTS="--mode=clingo --opt-mode=optN --models 0 --parallel-mode=$THREADS --outf=2 --stats=2 --enum-mode=$MODE"

if [[ "$WINDOW" ]]; then
  echo "🔍 Applying time window: $WINDOW"
  python "$FILTER_SCRIPT" "$ALL_FACTS" "$FILTER_FACTS" "$WIN_START" "$WIN_END"
  if [[ $? -ne 0 ]]; then
    echo "❌ Error: Failed to filter facts with time window."
    exit 1
  fi
  BASE_FILES="$FILTER_FACTS $APP_DIR/user_parameters/simple_event.lp $APP_DIR/domain/atemporal_facts.lp ./utils/auxiliary.lp ./encoding/expansion.lp ./encoding/linear.lp"
  BASE_FILES_2="$FILTER_FACTS $APP_DIR/user_parameters/simple_event.lp $APP_DIR/domain/atemporal_facts.lp ./utils/auxiliary.lp ./execution/parameters1.lp"
fi

if [[ "$REPAIR" == "no" ]]; then
  # Normal mode - simple and possibly complex events
  if [[ -f "$META_EVENT" ]]; then
    echo "⚙️  Processing both simple and meta- events..."
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" "$META_EVENT" ./execution/parameters1.lp >"$OUTPUT"
  else
    echo "⚙️  Processing only simple events (no meta_event.lp found)..."
    clingo $BASE_OPTS $BASE_FILES "$SIMPLE_EVENT" ./execution/parameters2.lp >"$OUTPUT"
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

  if [[ -f "$META_EVENT" ]]; then
    echo "🔍 Stage 2: Computing meta-events from repaired simple events..."
    python "$PYTHON_SCRIPT" "$BASE_FILES_2" "$META_EVENT" "$TEMP_JSON" --threads "$THREADS" >"$OUTPUT"
    rm -f "$TEMP_JSON"
  else
    echo "ℹ️  No complex_event.lp found, skipping Stage 2"
    mv "$TEMP_JSON" "$OUTPUT"
  fi
fi

echo "✅ Results saved to $OUTPUT"
