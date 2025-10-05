#!/usr/bin/env bash
set -euo pipefail

# install_ubuntu.sh
# Calls each script inside ./ubuntu step-by-step.
# Supports Bash and Zsh shells.

# Usage:
#   ./install_ubuntu.sh                     # interactive mode
#   ./install_ubuntu.sh --auto              # run all steps without prompts
#   ./install_ubuntu.sh --continue-on-error # continue even if a step fails
#   ./install_ubuntu.sh --dir=/path/to/ubuntu  # use custom directory

AUTO=false
CONTINUE_ON_ERROR=false
SCRIPTS_DIR="./ubuntu"

# Parse args
for arg in "$@"; do
  case "$arg" in
    --auto|-a) AUTO=true ;;
    --continue-on-error|-c) CONTINUE_ON_ERROR=true ;;
    --dir=*) SCRIPTS_DIR="${arg#*=}" ;;
    --help|-h)
      echo "Usage: $0 [--auto] [--continue-on-error] [--dir=PATH]"
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg"
      echo "Usage: $0 [--auto] [--continue-on-error] [--dir=PATH]"
      exit 1
      ;;
  esac
done

# Detect current shell (bash or zsh)
if [ -n "${ZSH_VERSION:-}" ]; then
  SHELL_CMD="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
  SHELL_CMD="bash"
else
  SHELL_CMD="bash"
fi

# Scripts in order
SCRIPTS=(
  "1_setupenv.sh"
  "2_setupROS.sh"
  "3_setupPX4_Gazebo.sh"
  "4_setupPython.sh"
  "5_isaac_sim_pegasus.sh"
)

# Basic checks
if [ ! -d "$SCRIPTS_DIR" ]; then
  echo "Error: directory '$SCRIPTS_DIR' not found. Create it or pass --dir=PATH."
  exit 2
fi

LOG_DIR="$SCRIPTS_DIR/logs"
mkdir -p "$LOG_DIR"

echo "-----------------------------------------"
echo " Using shell: $SHELL_CMD"
echo " Will run scripts from: $SCRIPTS_DIR"
echo " Logs will be saved in: $LOG_DIR"
echo "-----------------------------------------"
echo

# Ensure scripts exist and are executable
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
    # Continue even on errors
    if $SHELL_CMD "$script_path" 2>&1 | tee "$logfile"; then
      echo "Completed: $(basename "$script_path") ✅"
      return 0
    else
      local rc=${PIPESTATUS[0]:-1}
      echo "FAILED: $(basename "$script_path") ❌ (exit code: $rc). Continuing..."
      return $rc
    fi
  else
    # Stop on error
    $SHELL_CMD "$script_path" 2>&1 | tee "$logfile"
    echo "Completed: $(basename "$script_path") ✅"
    return 0
  fi
}

# --- Main loop ---
for s in "${SCRIPTS[@]}"; do
  script_path="$SCRIPTS_DIR/$s"
  logfile="$LOG_DIR/${s%.sh}.log"

  if [ "$AUTO" = false ]; then
    while true; do
      read -r -p "Run ${s}? [Enter=run / s=skip / q=quit] " resp
      resp_lc="$(echo "${resp:-}" | tr '[:upper:]' '[:lower:]')"
      if [ -z "$resp_lc" ]; then
        run_script "$script_path" "$logfile"
        break
      elif [[ "$resp_lc" == "s" || "$resp_lc" == "skip" ]]; then
        echo "Skipping $s"
        break
      elif [[ "$resp_lc" == "q" || "$resp_lc" == "quit" ]]; then
        echo "Aborting as requested."
        exit 0
      else
        echo "Type Enter to run, 's' to skip, or 'q' to quit."
      fi
    done
  else
    run_script "$script_path" "$logfile"
  fi
  echo
done

echo "-----------------------------------------"
echo "✅ All steps processed."
echo "Logs saved in: $LOG_DIR"
echo "Inspect with:"
echo "  ls -1 $LOG_DIR"
echo "  tail -n +1 $LOG_DIR/*.log"
echo "-----------------------------------------"
