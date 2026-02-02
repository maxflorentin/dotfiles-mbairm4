# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Load environment variables if .env exists
if [ -f "$DOTFILES/.env" ]; then
  source "$DOTFILES/.env"
fi

# Path to your oh-my-zsh installation.
export ZSH="${OH_MY_ZSH:-$HOME/.oh-my-zsh}"


autoload -U promptinit; promptinit
zstyle ':prompt:pure:path' color cyan
zstyle ':prompt:pure:virtualenv' color 242
zstyle ':prompt:pure:environment' render true
prompt pure

ZSH_THEME=""

HIST_STAMPS="yyyy-mm-dd"

ZSH_CUSTOM=$DOTFILES

plugins=(colorize compleat dirpersist autojump git history cp)

source $ZSH/oh-my-zsh.sh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim=nvim

alias docker=podman

# Created by `pipx` on 2025-06-06 16:54:45
export PATH="$PATH:${LOCAL_BIN:-$HOME/.local/bin}"
export EDITOR="nvim"
bindkey -v

[ -f "${AUTOJUMP_PROFILE:-/opt/homebrew/etc/profile.d/autojump.sh}" ] && . "${AUTOJUMP_PROFILE:-/opt/homebrew/etc/profile.d/autojump.sh}"
alias k=kubectl
alias docker=podman

# Added by Antigravity
export PATH="${ANTIGRAVITY_BIN:-$HOME/.antigravity/antigravity/bin}:$PATH"
source "${ZSH_SYNTAX_HIGHLIGHTING:-/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}"
export PATH="$HOME/.local/bin:$PATH"
export DOCKER_HOST="${DOCKER_HOST:-unix:///var/folders/c5/t8d_gq6s553_s5msp76hcc600000gn/T/podman/podman-machine-default-api.sock}"

uv-up() {
    source "${UV_SETUP_SCRIPT:-$HOME/Scripts/uv_setup.sh}"
}


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
            # Solo activar si no es el venv actual
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


asp() {
  local profile=$(aws configure list-profiles | fzf --height 40% --layout=reverse --border)
  if [[ -n "$profile" ]]; then
    export AWS_PROFILE=$profile
    echo "☁️  AWS Profile set to: $AWS_PROFILE"
  fi
}

unasp() {
  unset AWS_PROFILE
  echo "☁️  AWS_PROFILE unset."
}

export PATH="$HOME/Scripts/dotfiles:$PATH"
alias sqlit-conn='$HOME/Scripts/dotfiles/sqlit-add-connection.sh'
