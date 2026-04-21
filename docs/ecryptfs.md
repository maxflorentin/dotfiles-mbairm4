# ecryptfs: Encrypted home directories for client users

## Overview

Client users on the workstation have ecryptfs-encrypted home directories
for compliance. Since SSH uses key-based auth (no password), ecryptfs
can't mount automatically via PAM. Instead, `work connect` calls a
root-level helper script that mounts the home before the client session starts.

## Architecture

```
Mac (work connect)
  │
  ├─ 1. ssh max@workstation → sudo ecryptfs-auto-mount <client>
  │     (mounts encrypted home using stored passphrase)
  │
  └─ 2. ssh <client>@workstation → tmux-layout
        (home is now decrypted and accessible)
```

## Files

| Path | Owner | Mode | Purpose |
|------|-------|------|---------|
| `/usr/local/sbin/ecryptfs-auto-mount` | root | 755 | Mount helper (from dotfiles) |
| `/etc/ecryptfs/<client>.passphrase` | root | 600 | Login passphrase per client |
| `/home/.ecryptfs/<client>/` | root | — | ecryptfs config + encrypted data |
| `/etc/sudoers.d/ecryptfs-mount` | root | 440 | Allows admin to run mount helper |

## Setup (one-time, as admin)

### 1. Install the mount helper

```bash
sudo cp ~/.dotfiles/linux/ecryptfs-auto-mount /usr/local/sbin/ecryptfs-auto-mount
sudo chmod 755 /usr/local/sbin/ecryptfs-auto-mount
```

### 2. Store the client passphrase

```bash
sudo mkdir -p /etc/ecryptfs
sudo sh -c 'echo "THE_LOGIN_PASSPHRASE" > /etc/ecryptfs/<client>.passphrase'
sudo chmod 600 /etc/ecryptfs/<client>.passphrase
```

This is the **login password** of the client user (the one you'd type at
`ssh client@localhost`), NOT the mount passphrase.

### 3. Create the sudoers rule

```bash
echo 'max ALL=(root) NOPASSWD: /usr/local/sbin/ecryptfs-auto-mount' | sudo tee /etc/sudoers.d/ecryptfs-mount
sudo chmod 440 /etc/sudoers.d/ecryptfs-mount
sudo visudo -cf /etc/sudoers.d/ecryptfs-mount
```

### 4. Test

```bash
# From Mac:
work connect <client> <project>

# Or manually from workstation:
sudo /usr/local/sbin/ecryptfs-auto-mount <client>
sudo ls /home/<client>/   # should show decrypted files
```

## How it works

1. `work connect` calls `ssh max@workstation "sudo ecryptfs-auto-mount <client>"`
2. The script checks if the user has ecryptfs (skips if not)
3. Checks if already mounted (skips if yes — idempotent)
4. Reads the login passphrase from `/etc/ecryptfs/<client>.passphrase`
5. Unwraps the ecryptfs mount passphrase using `ecryptfs-unwrap-passphrase`
6. Inserts the key into the kernel keyring
7. Mounts the encrypted home at `/home/<client>/`

## Troubleshooting

### "passphrase file not found"
Create it: `sudo sh -c 'echo "pass" > /etc/ecryptfs/<client>.passphrase' && sudo chmod 600 /etc/ecryptfs/<client>.passphrase`

### "Signature not found in user keyring"
The ecryptfs mount passphrase couldn't be unwrapped. Verify the login
passphrase is correct: `ssh <client>@localhost` with password.

### Home shows placeholder files after reboot
The mount is not persistent across reboots (by design). It mounts on
first `work connect` after boot. If needed, manually:
`sudo /usr/local/sbin/ecryptfs-auto-mount <client>`

### ecryptfs home won't unmount
Only unmounts when no processes are using it. Check: `lsof +D /home/<client>`
Typically stays mounted as long as tmux is running (which is desired).

## Security notes

- Passphrase files are root-only (mode 600) — client users cannot read them
- The mount helper only runs as root via a restricted sudoers rule
- Admin (max) can mount any client's home but cannot read the passphrase
  without root access
- ecryptfs stays mounted while tmux sessions are active (processes hold the mount)
- On reboot, homes are encrypted until first `work connect`
