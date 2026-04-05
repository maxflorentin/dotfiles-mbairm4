# Add directories to the PATH and prevent to add the same directory multiple times upon shell reload.
add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# Load dotfiles binaries
add_to_path "$DOTFILES/bin"

# Load global Node installed binaries
add_to_path "${NODE_BIN:-$HOME/.node/bin}"
add_to_path "node_modules/.bin"

# Local bin (pipx, envy symlinks, etc.)
add_to_path "$HOME/.local/bin"

# Dotfiles scripts (jira, patent, etc.)
add_to_path "$HOME/Scripts/dotfiles"

# Antigravity
add_to_path "${ANTIGRAVITY_BIN:-$HOME/.antigravity/antigravity/bin}"

# fnm (Node version manager)
add_to_path "$HOME/.local/share/fnm"
command -v fnm &>/dev/null && eval "$(fnm env)"
