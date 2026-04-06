#!/bin/bash

# bootstrap: Set up Raspberry Pi (or Linux ARM) as dev server
# Run ON the target machine after fresh OS install
# Usage: curl -sL <raw-url> | bash  OR  scp + run locally

set -e

echo "=== Linux Dev Server Bootstrap ==="
echo ""

ARCH="$(uname -m)"
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/maxflorentin/dotfiles.git"

# --- Locale ---
echo "[1/9] Configuring locale..."
sudo locale-gen en_US.UTF-8 2>/dev/null || true
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 2>/dev/null || true
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# --- System update ---
echo "[2/9] Updating system..."
sudo apt-get update -qq && sudo apt-get upgrade -y -qq

# --- Core packages ---
echo "[3/9] Installing core packages..."
sudo apt-get install -y -qq \
    git curl wget unzip \
    build-essential cmake \
    tmux htop \
    openssh-server \
    wireguard openresolv \
    age \
    jq ripgrep fd-find bat fzf eza autojump \
    zsh

# --- Docker ---
echo "[4/9] Installing Docker..."
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
else
    echo "  already installed"
fi

# --- Node via fnm ---
echo "[5/9] Installing Node (via fnm)..."
if ! command -v fnm &>/dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts
else
    echo "  already installed"
fi

# --- Python (uv) ---
echo "[6/9] Installing Python tools..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "  already installed"
fi

# --- Neovim ---
echo "[7/9] Installing Neovim..."
if ! command -v nvim &>/dev/null; then
    if [ "$ARCH" = "aarch64" ]; then
        NVIM_VERSION="v0.11.6"
        curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-arm64.tar.gz"
        sudo tar xzf nvim-linux-arm64.tar.gz -C /opt/
        sudo ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
        rm nvim-linux-arm64.tar.gz
    else
        sudo apt-get install -y -qq neovim
    fi
else
    echo "  already installed"
fi

# --- Starship prompt ---
echo "[8/9] Installing Starship..."
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "  already installed"
fi

# --- Dotfiles ---
echo "[9/9] Setting up dotfiles..."

if [ -d "$DOTFILES_DIR" ]; then
    echo "  pulling latest..."
    git -C "$DOTFILES_DIR" pull
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Run the unified install script
"$DOTFILES_DIR/install"

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

# Create clients directory
mkdir -p "$HOME/clients"

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. Log out and back in (or: exec zsh)"
echo "  2. Initialize envy: envy-init && envy-new work"
echo "  3. From your Mac: work connect"
echo ""
echo "Dotfiles: ~/.dotfiles/"
echo "Clients:  ~/clients/"
