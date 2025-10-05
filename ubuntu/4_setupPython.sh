#!/bin/bash
set -e
set -o pipefail

# =====================================================
# Unified Robotics Development Environment Setup Script
# ROS2 Humble + PX4 SITL + Ignition Harmonic + Isaac Sim
# Virtualenv: air_research
# Tested on Ubuntu 22.04 LTS
# Author: TriBien
# =====================================================

echo "=== Step 1: System update and prerequisites ==="
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y \
  curl wget git lsb-release gnupg build-essential \
  python3-venv python3-pip python3-colcon-common-extensions \
  software-properties-common apt-transport-https

# =====================================================
# Step 2: Create and activate Python virtual environment
# =====================================================
echo "=== Creating Python virtual environment (.venv/air_research) ==="
if [ ! -d ~/.venvs ]; then mkdir -p ~/.venvs; fi
cd ~/.venvs
python3 -m venv air_research
source ~/.venvs/air_research/bin/activate

# Upgrade pip and tools
pip install --upgrade pip setuptools wheel

echo "🛠️ Starting install Torch..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

