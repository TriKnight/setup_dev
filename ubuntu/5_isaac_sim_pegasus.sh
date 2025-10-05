#!/usr/bin/env zsh
set -euo pipefail

# 5_isaac_sim_pegasus.sh
# Install Pegasus Simulator (for Isaac Sim + PX4)
# Requires: Isaac Sim already installed and working
# Tested on Ubuntu 22.04 + Zsh
# Based on Pegasus docs: https://pegasussimulator.github.io/PegasusSimulator/source/setup/installation.html

echo "=== Step 5: Install Pegasus Simulator ==="

# --- 1. Download & install Isaac Sim if not already done ---
if [ ! -d "$HOME/isaacsim" ]; then
  echo "-- Isaac Sim directory not found. Installing Isaac Sim 4.5.0..."
  cd "$HOME"
  mkdir -p isaacsim
  cd isaacsim

  wget "https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone%404.5.0-rc.36%2Brelease.19112.f59b3005.gl.linux-x86_64.release.zip"
  unzip *.zip
  rm *.zip

  ./post_install.sh || true
  ./isaac-sim.selector.sh || true

  echo "-- Isaac Sim installed at $HOME/isaacsim"
else
  echo "-- Isaac Sim directory exists: $HOME/isaacsim (skipping download/install)"
fi

# --- 2. Configure environment variables (for Pegasus) ---
echo "-- Configuring environment variables for Pegasus (Zsh)"

ZSHRC="$HOME/.zshrc"
if ! grep -q "export ISAACSIM_PATH" "$ZSHRC"; then
  cat >> "$ZSHRC" <<'EOF'

# Pegasus / Isaac Sim environment
export ISAACSIM_PATH="$HOME/isaacsim"
alias ISAACSIM_PYTHON="$ISAACSIM_PATH/python.sh"
alias ISAACSIM="$ISAACSIM_PATH/isaac-sim.sh"
EOF
  echo "-- Added ISAACSIM_PATH and aliases to $ZSHRC"
else
  echo "-- Environment entries already present in $ZSHRC"
fi

# Immediately apply in this shell
export ISAACSIM_PATH="$HOME/isaacsim"
alias ISAACSIM_PYTHON="$ISAACSIM_PATH/python.sh"
alias ISAACSIM="$ISAACSIM_PATH/isaac-sim.sh"

# --- 3. Clone Pegasus Simulator repo ---
echo "-- Cloning Pegasus Simulator repository (if not already present)"
cd "$HOME"
if [ ! -d PegasusSimulator ]; then
  git clone https://github.com/PegasusSimulator/PegasusSimulator.git
else
  echo "-- PegasusSimulator already cloned"
fi

cd PegasusSimulator

# --- 4. Install Pegasus Simulator extension (editable) ---
echo "-- Installing Pegasus extension as editable for Isaac Sim Python"
cd extensions
$ISAACSIM_PYTHON -m pip install --editable pegasus.simulator

echo "-- Pegasus Simulator extension installed (editable mode)"

# --- 5. PX4-Autopilot installation (optional / required for GUI mode) ---
echo "-- Installing PX4-Autopilot (for Pegasus GUI / PX4 integration)"
cd ~
if [ ! -d PX4-Autopilot ]; then
  git clone https://github.com/PX4/PX4-Autopilot.git
fi
cd PX4-Autopilot

git fetch --tags
git checkout v1.14.3
git submodule update --init --recursive

sudo apt install -y git make cmake python3-pip
pip install --upgrade pip
pip install kconfiglib jinja2 empy jsonschema pyros-genmsg packaging toml numpy future

make px4_sitl_default none || true

echo "-- PX4-Autopilot set up for Pegasus (v1.14.3)"

echo "=== Pegasus Simulator installation done! ==="
echo "👉 To use Pegasus:"
echo "  1. Launch Isaac Sim"
echo "  2. Open 'Window → Extensions'"
echo "  3. Add path: \$HOME/PegasusSimulator/extensions"
echo "  4. Enable the Pegasus extension"
echo "Then restart Isaac Sim."
