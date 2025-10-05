#!/bin/bash

# Exit on any error
set -e

echo "🤖 Starting ROS 2 Humble installation for Ubuntu 22.04..."

# 1. Setup locale
echo "🌍 Setting up locale..."
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 2. Add ROS 2 apt repository
echo "🔐 Adding ROS 2 GPG key..."
sudo apt install -y curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "📦 Adding ROS 2 apt source..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 3. Install ROS 2 Humble
echo "📥 Installing ROS 2 Humble Desktop..."
sudo apt update
sudo apt install -y ros-humble-desktop

# 4. Source ROS 2 setup script automatically
echo "🔧 Setting up ROS 2 environment..."
echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc
source ~/.zshrc

# 5. Install colcon and development tools
echo "🧰 Installing colcon and dependencies..."
sudo apt install -y python3-colcon-common-extensions python3-rosdep python3-argcomplete

# 6. Initialize rosdep
echo "🔄 Initializing rosdep..."
sudo rosdep init || true  # Ignore if already initialized
rosdep update

echo "✅ ROS 2 Humble installation complete!"
echo "💡 Restart your terminal or run 'source ~/.zshrc' to start using ROS 2."
