#!/bin/bash

# fresh.sh: Set up a new Mac from scratch
# Run after cloning dotfiles to ~/.dotfiles/

set -e

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# Load env vars if available
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

echo "Setting up your Mac..."
echo ""

# Xcode CLI Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Re-run this script after Xcode tools finish installing."
    exit 0
else
    echo "Xcode CLI Tools: installed"
fi

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew: installed"
fi

# Brew bundle
echo "Installing Homebrew packages..."
brew update
brew bundle --file "$DOTFILES/macos/Brewfile"

# Run the common install script (symlinks, nvim, scripts)
"$DOTFILES/install"

# Mackup restore (if synced)
if command -v mackup &>/dev/null && [ -f "$HOME/.mackup.cfg" ]; then
    echo ""
    echo "Mackup is ready. Run 'mackup restore' to restore app preferences."
fi

# macOS defaults
if [ -f "$DOTFILES/macos/defaults.sh" ]; then
    echo ""
    read -p "Apply macOS defaults? (y/n): " apply_defaults
    if [ "$apply_defaults" = "y" ]; then
        source "$DOTFILES/macos/defaults.sh"
    fi
fi

echo ""
echo "Mac setup complete. Restart your terminal: exec zsh"
