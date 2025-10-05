#!/bin/bash
set -euo pipefail

# run_steps_sequential.sh
# Calls each script inside ./ubuntu step-by-step (interactive by default).
# Usage:
#   ./run_steps_sequential.sh            # interactive
#   ./run_steps_sequential.sh --auto     # run all steps without prompts
#   ./run_steps_sequential.sh --continue-on-error  # continue even if a step fails
#   ./run_steps_sequential.sh --dir /path/to/ubuntu  # point to custom dir

AUTO=false
CONTINUE_ON_ERROR=false
SCRIPTS_DIR="./ubuntu"

# parse args
for arg in "$@"; do
  case "$arg" in
    --auto|-a) AUTO=true ;;
    --continue-on-error|-c) CONTINUE_ON_ERROR=true ;;
    --dir=*) SCRIPTS_DIR="${arg#*=}" ;;
    --help|-h) echo "Usage: $0 [--auto] [--continue-on-error] [--dir=PATH]"; exit 0 ;;
    *) echo "Unknown arg: $arg"; echo "Usage: $0 [--auto] [--continue-on-error] [--dir=PATH]"; exit 1 ;;
  esac
done

# scripts in order
SCRIPTS=(
  "1_setupenv.sh"
  "2_setupROS.sh"
  "3_setupPX4_Gazebo.sh"
  "4_setupPython.sh"
)

# basic checks
if [ ! -d "$SCRIPTS_DIR" ]; then
  echo "Error: directory '$SCRIPTS_DIR' not found. Create it or pass --dir=PATH."
  exit 2
fi

LOG_DIR="$SCRIPTS_DIR/logs"
mkdir -p "$LOG_DIR"

echo "Will run scripts from: $SCRIPTS_DIR"
echo "Logs will be written to: $LOG_DIR"
echo

# ensure scripts exist and are executable (make executable if needed)
for s in "${SCRIPTS[@]}"; do
  if [ ! -f "$SCRIPTS_DIR/$s" ]; then
    echo "Error: missing script: $SCRIPTS_DIR/$s"
    exit 3
  fi
  chmod +x "$SCRIPTS_DIR/$s" || true
done

run_script() {
  local script_path="$1"
  local logfile="$2"

  echo "-----"
  echo "Starting: $(basename "$script_path")  -- $(date +"%Y-%m-%d %H:%M:%S")"
  echo "Log: $logfile"
  echo "-----"

  if [ "$CONTINUE_ON_ERROR" = true ]; then
    # continue on error: capture exit code, but don't exit wrapper
    if bash "$script_path" 2>&1 | tee "$logfile"; then
      echo "Completed: $(basename "$script_path") (success)"
      return 0
    else
      local rc=${PIPESTATUS[0]:-1}
      echo "FAILED: $(basename "$script_path") (exit code: $rc). Continuing due to --continue-on-error."
      return $rc
    fi
  else
    # strict: exit on first failure (set -e will enforce this)
    bash "$script_path" 2>&1 | tee "$logfile"
    echo "Completed: $(basename "$script_path") (success)"
    return 0
  fi
}

# main loop
for s in "${SCRIPTS[@]}"; do
  script_path="$SCRIPTS_DIR/$s"
  logfile="$LOG_DIR/${s%.sh}.log"

  if [ "$AUTO" = false ]; then
    # interactive prompt
    while true; do
      read -r -p "Run ${s}? [Enter=run / s=skip / q=quit] " resp
      resp="${resp:-}"    # empty if enter
      resp_lc="$(printf '%s' "$resp" | tr '[:upper:]' '[:lower:]')"
      if [ -z "$resp_lc" ]; then
        # run
        if run_script "$script_path" "$logfile"; then
          break
        else
          # if not CONTINUE_ON_ERROR, run_script would have exited
          break
        fi
      fi
      if [ "$resp_lc" = "s" ] || [ "$resp_lc" = "skip" ]; then
        echo "Skipping $s"
        break
      fi
      if [ "$resp_lc" = "q" ] || [ "$resp_lc" = "quit" ]; then
        echo "Aborting as requested."
        exit 0
      fi
      echo "Type Enter to run, 's' to skip, 'q' to quit."
    done
  else
    # auto mode: run without prompting
    run_script "$script_path" "$logfile"
  fi

  echo
done

echo "All requested steps processed. Summary logs in: $LOG_DIR"
echo "You can inspect logs with: ls -1 $LOG_DIR && tail -n +1 $LOG_DIR/*.log"
echo "Done."
