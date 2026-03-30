# Pi Workstation

Headless dev server for isolated freelance workspaces.
Client traffic stays on the server. Your Mac stays clean.

## Components

| File | Runs on | Description |
|------|---------|-------------|
| `pi-bootstrap` | Server | Installs the full stack (Docker, Node, Neovim, WireGuard, etc.) |
| `work` | Mac | CLI to manage workspaces, VPNs, sessions, and monitoring |
| `tmux-layout` | Server | Creates per-client tmux workspace layouts |
| `.tmux.conf` | Server | Minimal tmux theme (Pure/Starship style) |

## `work` CLI

```bash
work connect [client] [project]  # SSH + tmux (fuzzy project match)
work setup <client>              # Create workspace + envy context
work status                      # Server status (RAM, Docker, VPNs, sessions)
work health                      # Quick health check with alerts
work watch [seconds]             # Live monitor (default: 30s)
work sync <client> [dir]         # Rsync local dir to server
work browse <client>             # Isolated Chrome via SOCKS proxy
work browse-stop                 # Stop SOCKS proxy
work vpn-up <client>             # Start client WireGuard VPN
work vpn-down <client>           # Stop client VPN
work destroy <client>            # Delete all client data
```

## Setup

1. Flash Raspberry Pi OS Lite (64-bit) with SSH enabled
2. `ssh-copy-id` your key to the server
3. Run `pi-bootstrap` on the server
4. Add SSH config entry on your Mac

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `WORK_PI_HOST` | `pi-workstation` | Server hostname or IP |
| `WORK_PI_USER` | `max` | SSH user |
| `WORK_PROXY_PORT` | `1080` | SOCKS proxy port for `browse` |

### Migrating to a different server

The setup is portable. To move to a new machine (bigger Pi, mini PC, VPS, etc.):

1. Run `pi-bootstrap` on the new host
2. Clone your dotfiles repos
3. Copy WireGuard configs and envy keys
4. Update `WORK_PI_HOST` (env var or `~/.ssh/config`)

Everything else (`work` CLI, tmux layouts, aliases) works unchanged.
