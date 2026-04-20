#!/bin/bash

# tailscale-mutt-setup.sh: Set up a second Tailscale instance for MuttData
# Run as admin (with sudo). One-time setup.
#
# Creates:
#   - systemd service: tailscaled-mutt (port 41642, separate state)
#   - sudoers drop-in: /etc/sudoers.d/tailscale-mutt
#   - wrapper script:  /usr/local/bin/tailscale-mutt
#
# After setup, the mutt user can:
#   tailscale-mutt up              # connect to mutt tailnet
#   tailscale-mutt down            # disconnect
#   tailscale-mutt status          # check connection
#   tailscale-mutt start/stop      # manage the daemon
#
# Usage: sudo ./tailscale-mutt-setup.sh [username]

set -e

USER="${1:-mutt}"
STATE_DIR="/var/lib/tailscale-mutt"
SOCKET="/run/tailscale-mutt.sock"
SERVICE="tailscaled-mutt"
PORT=41642

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: run with sudo"
    exit 1
fi

if ! id "$USER" &>/dev/null; then
    echo "Error: user '$USER' does not exist"
    exit 1
fi

if ! command -v tailscaled &>/dev/null; then
    echo "Error: tailscale not installed"
    exit 1
fi

echo "Setting up Tailscale instance for user: $USER"
echo ""

# --- State directory ---
mkdir -p "$STATE_DIR"
echo "  created: $STATE_DIR"

# --- systemd service ---
cat > /etc/systemd/system/${SERVICE}.service <<EOF
[Unit]
Description=Tailscale (MuttData)
After=network-pre.target NetworkManager.service systemd-resolved.service
Wants=network-pre.target

[Service]
ExecStartPre=/usr/sbin/tailscaled --cleanup --state=${STATE_DIR}/tailscaled.state --socket=${SOCKET}
ExecStart=/usr/sbin/tailscaled --state=${STATE_DIR}/tailscaled.state --socket=${SOCKET} --port=${PORT}
ExecStopPost=/usr/sbin/tailscaled --cleanup --state=${STATE_DIR}/tailscaled.state --socket=${SOCKET}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "$SERVICE"
echo "  service: $SERVICE enabled and started"

# --- sudoers drop-in ---
SUDOERS_FILE="/etc/sudoers.d/tailscale-mutt"
TAILSCALE_BIN="$(command -v tailscale)"
SYSTEMCTL_BIN="$(command -v systemctl)"

cat > "$SUDOERS_FILE" <<EOF
# Allow $USER to manage the tailscale-mutt instance (no password)
$USER ALL=(ALL) NOPASSWD: ${TAILSCALE_BIN} --socket=${SOCKET} *
$USER ALL=(ALL) NOPASSWD: ${SYSTEMCTL_BIN} start ${SERVICE}
$USER ALL=(ALL) NOPASSWD: ${SYSTEMCTL_BIN} stop ${SERVICE}
$USER ALL=(ALL) NOPASSWD: ${SYSTEMCTL_BIN} restart ${SERVICE}
$USER ALL=(ALL) NOPASSWD: ${SYSTEMCTL_BIN} status ${SERVICE}
EOF
chmod 440 "$SUDOERS_FILE"
# Validate sudoers syntax
if ! visudo -cf "$SUDOERS_FILE" &>/dev/null; then
    echo "  ERROR: sudoers syntax invalid, removing"
    rm -f "$SUDOERS_FILE"
    exit 1
fi
echo "  sudoers: $SUDOERS_FILE"

# --- wrapper script ---
cat > /usr/local/bin/tailscale-mutt <<'WRAPPER'
#!/bin/bash
# Wrapper for the MuttData Tailscale instance
SOCKET="/run/tailscale-mutt.sock"
SERVICE="tailscaled-mutt"

case "$1" in
    start|stop|restart|status-svc)
        # Service management (status-svc to avoid collision with tailscale status)
        cmd="$1"
        [ "$cmd" = "status-svc" ] && cmd="status"
        sudo systemctl "$cmd" "$SERVICE"
        ;;
    "")
        echo "Usage: tailscale-mutt <command>"
        echo ""
        echo "Tailscale commands:"
        echo "  up [--authkey=...]   Connect to MuttData tailnet"
        echo "  down                 Disconnect"
        echo "  status               Show connection status"
        echo "  ip                   Show Tailscale IP"
        echo "  ping <host>          Ping a tailnet host"
        echo ""
        echo "Service commands:"
        echo "  start                Start the daemon"
        echo "  stop                 Stop the daemon"
        echo "  restart              Restart the daemon"
        echo "  status-svc           Show daemon service status"
        ;;
    *)
        sudo tailscale --socket="$SOCKET" "$@"
        ;;
esac
WRAPPER
chmod +x /usr/local/bin/tailscale-mutt
echo "  wrapper: /usr/local/bin/tailscale-mutt"

echo ""
echo "Done. Service is running."
echo ""
echo "Next: authenticate from user '$USER' (or here with the authkey):"
echo "  tailscale-mutt up --authkey=tskey-..."
echo ""
echo "Or interactive (opens browser):"
echo "  tailscale-mutt up"
