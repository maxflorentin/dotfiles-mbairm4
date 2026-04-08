# Pi Workstation

Headless dev server for isolated freelance workspaces.
Client traffic stays on the server. Your Mac stays clean.

## Components

| File | Runs on | Description |
|------|---------|-------------|
| `linux/bootstrap.sh` | Server | Installs the full stack (Docker, Node, Claude Code, Neovim, Starship, etc.) |
| `linux/work` | Mac + Pi | CLI to manage workspaces, VPNs, sessions, and monitoring |
| `linux/tmux-layout` | Server | Creates per-client tmux workspace layouts |
| `linux/tmux.conf` | Server | Minimal tmux theme (Pure/Starship style) |

## `work` CLI

```bash
work connect [client] [project]  # SSH + tmux (fuzzy project match)
work setup <client>              # Create workspace + envy context + .clientrc
work status                      # Server status (RAM, Docker, VPNs, sessions)
work health                      # Quick health check with alerts
work watch [seconds]             # Live monitor (default: 30s)
work sync <client> [dir]         # Rsync local dir to server
work browse <client>             # Isolated Chrome via SOCKS proxy
work browse-stop                 # Stop SOCKS proxy
work vpn-up <client>             # Start client WireGuard VPN
work vpn-down <client>           # Stop client VPN
work ssh-keygen <client> [host]  # Generate ed25519 key for client
work report [--day|--week|--month] # Time tracking report
work destroy <client>            # Delete all client data
```

## Setup

1. Flash Raspberry Pi OS Lite (64-bit) with SSH enabled
2. `ssh-copy-id` your key to the server
3. Run `linux/bootstrap.sh` on the server
4. Add SSH config entry on your Mac

## Post-Bootstrap

### Home encryption (ecryptfs)

Optional but recommended for client data isolation:

```bash
# Create encryption user first
sudo useradd -mb /home -s /bin/bash -G sudo encryption_user
sudo passwd encryption_user

# Log out, log in as encryption_user, then:
sudo ecryptfs-migrate-home -u max

# Log out, log in as max, verify files, then cleanup:
sudo userdel --remove encryption_user
sudo rm -rf /home/max.*
```

The bootstrap script automatically handles the SSH authorized_keys fix for ecryptfs (moves keys to `/etc/ssh/authorized_keys/%u` so SSH works before home is mounted).

Save the recovery key: `ecryptfs-unwrap-passphrase ~/.ecryptfs/wrapped-passphrase`

### DNS filtering (NextDNS via dnsmasq)

```bash
sudo apt install -y dnsmasq
sudo tee /etc/dnsmasq.d/nextdns.conf << EOF
no-resolv
bogus-priv
strict-order
server=45.90.28.0
server=45.90.30.0
add-cpe-id=YOUR_NEXTDNS_ID
EOF
sudo systemctl restart dnsmasq
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

### Compliance tools (client-specific)

Some clients require additional security software. These are NOT part of the standard bootstrap:

```bash
# ClamAV (antivirus)
sudo apt install -y clamav clamav-daemon
sudo freshclam && sudo systemctl enable clamav-daemon

# Wazuh agent (SIEM) — follow client-provided installer

# Tailscale (VPN mesh) — follow client instructions for auth key
```

## Client Onboarding

```bash
# From Mac — creates dirs, envy context, venv, .clientrc template:
work setup <client>

# Connect and customize .clientrc:
work connect <client>
vim ~/clients/<client>/.clientrc
```

Each client gets: isolated directory, envy secrets, Python venv, .clientrc (env vars + aliases), optional .kube/config and WireGuard VPN.

## VS Code Remote

Install the "Remote - SSH" extension. Connect via `Cmd+Shift+P` > "Remote-SSH: Connect to Host" > `pi-workstation`. Edits, terminal, and extensions run on the server.

## Client VPNs

Each client can have its own WireGuard config at `/etc/wireguard/<client>.conf`.

`work vpn-up` checks for full-tunnel configs (`AllowedIPs = 0.0.0.0/0`) and warns before activation, since routing all traffic through the client VPN would kill your SSH session. Always use split tunneling — only route the client's internal subnets.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `WORK_PI_HOST` | `pi-workstation` | Server hostname or IP |
| `WORK_PI_USER` | `max` | SSH user |
| `WORK_PROXY_PORT` | `1080` | SOCKS proxy port for `browse` |

## Migration

The setup is portable. To move to a new machine (bigger Pi, mini PC, VPS, etc.):

1. Run `linux/bootstrap.sh` on the new host
2. Copy `~/clients/` and `~/.envy/` from old server
3. Copy WireGuard configs from `/etc/wireguard/`
4. Update `WORK_PI_HOST` (env var or `~/.ssh/config`)

Everything else (`work` CLI, tmux layouts, aliases) works unchanged.
