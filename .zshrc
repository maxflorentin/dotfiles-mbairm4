# Dotfiles
export DOTFILES=$HOME/.dotfiles

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # Timestamps in history
setopt SHARE_HISTORY          # Share between sessions
setopt HIST_IGNORE_DUPS       # No consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate
setopt HIST_REDUCE_BLANKS     # Trim whitespace
setopt HIST_VERIFY            # Show before executing !command
HIST_STAMPS="yyyy-mm-dd"

# Directory navigation
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD             # Push dirs to stack on cd
setopt PUSHD_IGNORE_DUPS      # No duplicate dirs in stack
setopt PUSHD_SILENT           # Don't print stack on pushd

# Completion
autoload -Uz compinit
# Only regenerate completion dump once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Vi mode
bindkey -v

# Environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR="nvim"
# Docker (macOS uses podman socket, Linux uses native Docker)
if [[ "$(uname)" == "Darwin" ]]; then
    export DOCKER_HOST="${DOCKER_HOST:-unix:///var/folders/c5/t8d_gq6s553_s5msp76hcc600000gn/T/podman/podman-machine-default-api.sock}"
fi

# Load dotfiles config
source "$DOTFILES/path.zsh"
source "$DOTFILES/aliases.zsh"

# Autojump
[ -f "${AUTOJUMP_PROFILE:-/opt/homebrew/etc/profile.d/autojump.sh}" ] && . "${AUTOJUMP_PROFILE:-/opt/homebrew/etc/profile.d/autojump.sh}"

# Syntax highlighting
if [[ "$(uname)" == "Darwin" ]]; then
    source "${ZSH_SYNTAX_HIGHLIGHTING:-/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}"
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Auto-activate Python venvs
autoload -U add-zsh-hook

auto_activate_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_dir=$(dirname "$VIRTUAL_ENV")
        if [[ "$PWD"/ != "$venv_dir"/* ]] && [[ "$PWD" != "$venv_dir" ]]; then
            deactivate 2>/dev/null
        fi
    fi

    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            if [[ "$VIRTUAL_ENV" != "$dir/.venv" ]]; then
                source "$dir/.venv/bin/activate"
            fi
            return
        fi
        dir=$(dirname "$dir")
    done
}

add-zsh-hook chpwd auto_activate_venv
auto_activate_venv

# UV setup (lazy)
uv-up() {
    source "${UV_SETUP_SCRIPT:-$HOME/Scripts/uv_setup.sh}"
}

# AWS profile switcher
asp() {
  local profile=$(aws configure list-profiles | fzf --height 40% --layout=reverse --border)
  if [[ -n "$profile" ]]; then
    export AWS_PROFILE=$profile
    echo "AWS Profile set to: $AWS_PROFILE"
  fi
}

unasp() {
  unset AWS_PROFILE
  echo "AWS_PROFILE unset."
}

# Starship prompt
export STARSHIP_CONFIG="$DOTFILES/starship.toml"
eval "$(starship init zsh)"

# Google Cloud SDK
if [ -f "$HOME/Projects/gcp/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Projects/gcp/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/Projects/gcp/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Projects/gcp/google-cloud-sdk/completion.zsh.inc"; fi
