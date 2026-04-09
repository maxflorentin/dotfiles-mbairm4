# dotfiles

Cross-platform dotfiles for macOS and Linux (Raspberry Pi).

## Quick start

```bash
git clone git@github.com:maxflorentin/dotfiles-mbairm4.git ~/.dotfiles
cd ~/.dotfiles
./install
```

**Fresh Mac?** After `./install`, run `macos/fresh.sh` for Homebrew, apps, and macOS defaults.

**Fresh Pi/Linux?** Run `linux/bootstrap.sh` to install everything from scratch.

## Structure

```
~/.dotfiles/
├── install              # Idempotent setup (detects OS)
├── shell/               # zshrc, aliases, path, starship
├── macos/               # Brewfile, fresh.sh, defaults, mackup
├── linux/               # tmux, bootstrap, work CLI, tmux-layout
├── editors/             # nvim, vscode, iterm2
├── scripts/             # envy, gh-clone-org, brew-sync, etc.
└── docs/                # pi-workstation, envy
```

## What `./install` does

- Symlinks `.zshrc`, nvim config, gitignore
- Links scripts to `~/.local/bin`
- **macOS**: VS Code settings, mackup, work CLI
- **Linux**: tmux config, tmux-layout, work CLI

Safe to run multiple times.

## Key tools

| Tool | What it does |
|------|-------------|
| `work` | Manage Pi workspaces (connect, setup, sync, VPN, browse) |
| `envy-*` | Age-encrypted secret management |
| `brew-sync` | Auto-dump Brewfile and commit changes |
| `gh-clone-org` | Clone all repos from a GitHub org |

## Docs

- [Pi Workstation](docs/pi-workstation.md) - Raspberry Pi dev server setup
- [Envy](docs/envy.md) - Encrypted secrets manager
