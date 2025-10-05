#!/bin/bash
set -e

# === PX4 + Ignition Harmonic Installation Script ===
# Tested on Ubuntu 22.04 / 24.04
# Author: TriKnight
# ================================================

echo "=== Updating system and installing prerequisites ==="
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git wget curl lsb-release gnupg python3-pip

# --- Step 1: Clone PX4-Autopilot repository ---
echo "=== Cloning PX4-Autopilot repository ==="
if [ ! -d PX4-Autopilot ]; then
  git clone https://github.com/PX4/PX4-Autopilot.git --recursive
fi

cd PX4-Autopilot

# --- Step 2: Run PX4 dependencies script ---
echo "=== Installing PX4 dependencies ==="
bash ./Tools/setup/ubuntu.sh --no-sim-tools

# --- Step 3: Install Ignition Harmonic (Fortress successor) ---
echo "=== Installing Ignition Harmonic ==="

# Add Gazebo (Ignition) package source
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:gz/gz-harmonic
sudo apt update -y

# Install core Harmonic packages
sudo apt install -y gz-harmonic

# Optional tools (useful for visualization and testing)
sudo apt install -y ros-dev-tools libgz-gui8-dev libgz-msgs10-dev libgz-transport14-dev

# --- Step 4: Install PX4 simulation dependencies ---
echo "=== Installing PX4 simulation dependencies ==="
bash ./Tools/setup/ubuntu.sh --no-nuttx

# --- Step 5: Build PX4 with Ignition ---
echo "=== Building PX4 for Ignition Harmonic ==="
make px4_sitl gz_harmonic

echo "===================================================="
echo "✅ PX4 SITL with Ignition Harmonic successfully built!"
echo "Run simulation with:"
echo "  make px4_sitl gz_harmonic"
echo "===================================================="

