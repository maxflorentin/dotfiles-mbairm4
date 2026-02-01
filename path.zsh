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

add_to_path "$HOME/.local/bin"
