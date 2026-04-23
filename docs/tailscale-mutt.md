# Secondary Tailscale instance for work VPN

## Overview

Runs a second `tailscaled` daemon alongside the personal one to connect
to a work tailnet. Uses separate TUN device, socket, port, and state
to avoid conflicts.

Key design decisions:
- `--netfilter-mode=off` was the intended isolation flag but was removed in tailscaled ≥1.96 — separation relies solely on distinct TUN devices now
- `--tun=ts-mutt` avoids TUN device name collision (primary uses `tailscale0`)
- Real TUN device (not `userspace-networking`) is required for subnet routing — userspace mode does not install kernel routes, so `ip route` won't have VPC subnets and kubectl/curl won't reach them
- No `DevicePolicy` needed — tailscaled ≥1.96 handles TPM errors gracefully without crashing
- Single instance (not per-env) — connect/disconnect as needed
- Client user runs commands via sudoers (no full sudo)

## Architecture

```
tailscaled (personal)          tailscaled-mutt (work)
├── socket: /run/tailscale     ├── socket: /run/tailscale-mutt.sock
├── port: 41641                ├── port: 41642
├── tun: tailscale0            ├── tun: ts-mutt
├── state: /var/lib/tailscale  ├── state: /var/lib/tailscale-mutt
└── netfilter: on              └── netfilter: off
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

### Personal tailscale lost connectivity after `up`
The `--netfilter-mode=off` flag should prevent this. If it still happens:
1. `tailscale-mutt down` (disconnect work VPN)
2. `sudo systemctl restart tailscaled` (restart personal)
3. Check `tailscale status` to confirm personal is back

### "device or resource busy" on startup
Another instance is using the TUN device. Check:
`ip link show ts-mutt` — if it exists from a crashed instance:
`sudo ip link delete ts-mutt`

### Socket not found
The daemon isn't running: `tailscale-mutt start`

### TPM timeout on startup
The `DevicePolicy=closed` in the systemd unit should prevent this.
If it still occurs, check that the service file has the correct
DevicePolicy/DeviceAllow directives.
