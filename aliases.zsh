# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="omz reload"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="${COREUTILS_BIN:-/opt/homebrew/opt/coreutils/libexec/gnubin}/ls -AhlFo --color --group-directories-first"
alias phpstorm='open -a "${PHPSTORM_APP:-/Applications/PhpStorm.app}" "`pwd`"'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias compile="commit 'compile'"
alias timestamp="date +%s"
alias version="commit 'version'"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"

# Common
alias c="clear"
alias docker="podman"

# Docker/Podman compatibility aliases
alias dps='podman ps'
alias dimgs='podman images'
alias drun='podman run'
alias dbuild='podman build'
alias dstart='podman start'
alias dstop='podman stop'
alias drm='podman rm'
alias drmi='podman rmi'
alias dexec='podman exec'
alias dlogs='podman logs'
alias dnet='podman network'
alias dvol='podman volume'

# Docker
alias docker-composer="podman-compose"

# SQL Server
alias mssql="docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=${MSSQL_PASSWORD:-LaravelWow1986!} -p 1433:1433 mcr.microsoft.com/mssql/server:2017-latest"

# Git
alias gs="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force-with-lease"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias prune="git fetch --prune"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"

alias jira-ticket="pbpaste | jira-create"
