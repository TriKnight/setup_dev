#!/bin/bash

# Exit on error
set -e

echo "🛠️ Starting Zsh setup..."

# 1. Install Zsh
echo "📦 Installing Zsh..."
sudo apt update
sudo apt install -y zsh git curl

# 2. Install Oh My Zsh
echo "⚙️ Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Install zsh-autosuggestions
echo "💡 Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 4. Install zsh-syntax-highlighting
echo "🔍 Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 5. Install Powerlevel10k theme
echo "🎨 Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# 6. Configure .zshrc
echo "📝 Configuring .zshrc..."

cat > ~/.zshrc <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Optional: Load Powerlevel10k configuration if exists
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

# 7. Set Zsh as default shell
echo "🖥️ Changing default shell to Zsh..."
chsh -s $(which zsh)

echo "✅ Zsh setup complete!"
echo "🔁 Please restart your terminal or log out and log back in to apply changes."

# Make it executable
# chmod +x setup_zsh.sh
# ./setup_zsh.sh