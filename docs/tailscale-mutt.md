# Secondary Tailscale instance for work VPN

## Overview

Runs a second `tailscaled` daemon alongside the personal one to connect
to a work tailnet. Uses separate TUN device, socket, port, and state
to avoid conflicts.

Key design decisions:
- `--tun=userspace-networking` avoids TUN/iptables/routing conflicts entirely
- `--accept-routes` is BLOCKED in the wrapper (causes routing conflicts that kill personal tailscale)
- No `DevicePolicy` needed — tailscaled >=1.96 handles TPM errors gracefully
- Single instance (not per-env) — connect/disconnect as needed
- Client user runs commands via sudoers (no full sudo)

## Architecture

```
tailscaled (personal)          tailscaled-mutt (work)
├── socket: /run/tailscale     ├── socket: /run/tailscale-mutt.sock
├── port: 41641                ├── port: 41642
├── tun: tailscale0            ├── tun: userspace-networking
├── state: /var/lib/tailscale  ├── state: /var/lib/tailscale-mutt
└── netfilter: on              └── netfilter: n/a (userspace)
```

## Setup (one-time, as admin)

```bash
sudo ~/.dotfiles/linux/tailscale-mutt-setup.sh <client-user>
```

This creates the systemd service, wrapper script, and sudoers rules.
Also cleans up old per-env services (dev/stage/prod) if they exist.

## Daily usage (as client user)

```bash
# Connect to work tailnet
tailscale-mutt up --authkey=tskey-auth-...

# Check status
tailscale-mutt status

# Disconnect
tailscale-mutt down

# Daemon management
tailscale-mutt stop      # stop the daemon entirely
tailscale-mutt start     # start it back
tailscale-mutt restart   # restart
```

## Files

| Path | Purpose |
|------|---------|
| `/etc/systemd/system/tailscaled-mutt.service` | systemd unit |
| `/usr/local/bin/tailscale-mutt` | wrapper script |
| `/etc/sudoers.d/tailscale-mutt` | passwordless sudo rules |
| `/var/lib/tailscale-mutt/` | state directory |
| `/run/tailscale-mutt.sock` | daemon socket |

## Troubleshooting

### NEVER use --accept-routes
`--accept-routes` imports subnet routes from the work tailnet that
overwrite personal tailscale routing, causing total loss of SSH access.
The wrapper script blocks this flag. Access work hosts by their
Tailscale IPs (100.x.x.x) directly — no routes needed.

### Personal tailscale lost connectivity
1. Connect via LAN: `ssh max@192.168.68.52`
2. `sudo systemctl stop tailscaled-mutt`
3. `sudo systemctl restart tailscaled`
4. Verify: `tailscale status`

### Socket not found
The daemon isn't running: `tailscale-mutt start`

### Service won't start after reboot
The service is disabled by default after the accept-routes incident.
Re-enable: `sudo systemctl enable --now tailscaled-mutt`
