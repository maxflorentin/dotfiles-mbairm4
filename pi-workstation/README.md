# Pi 400 Workstation - Freelance Isolation

Raspberry Pi 400 como dev server aislado para trabajo freelance.
El cliente ve la Pi. Tu Mac queda intocable.

## Arquitectura

```
                          LAN (casa)                          Remoto (4G, WiFi publico)
                    ┌─────────────────────┐              ┌──────────────────────┐
                    │                     │              │                      │
Mac (personal)      │   Pi 400 (clientes) │   iPhone     │   Pi 400             │
├── SSH (LAN) ──────┤   ├── ~/clients/    │   ├── Tailscale (WireGuard) ───────┤
├── work CLI ───────┤   │   ├── mutt/     │   └── Termius/Blink ──> SSH ───────┤
├── Chrome aislado  │   │   └── acme/     │              │                      │
│   (SOCKS proxy) ──┤   ├── Docker        │              └──────────────────────┘
│                   │   ├── WireGuard VPN  │
└── Tailscale ──────┤   ├── Tailscale     │
                    │   ├── envy secrets  │
                    │   └── nvim+tmux     │
                    └─────────────────────┘
```

## Componentes

### `work` (CLI en tu Mac)

Comando central para gestionar todo desde la Mac. Vive en tu PATH.

```bash
work setup <client>       # Crear workspace + envy context
work connect [client]     # SSH + tmux session
work status               # Estado de la Pi (RAM, Docker, VPNs, sesiones)
work sync <client> [dir]  # rsync local -> Pi
work browse <client>      # Chrome aislado via proxy SOCKS (Pi network/VPN)
work browse-stop          # Cerrar proxy SOCKS
work vpn-up <client>      # Levantar WireGuard VPN del cliente
work vpn-down <client>    # Bajar VPN
work destroy <client>     # Borrar TODO de un cliente
```

### `pi-bootstrap` (corre en la Pi)

Script de setup inicial que instala todo el stack:
- **git, curl, tmux, htop, zsh** - herramientas base
- **Docker CE** - containers (ARM64)
- **fnm + Node LTS** - desarrollo Node
- **uv** - gestor de Python/venvs
- **Neovim** - editor
- **Starship** - prompt
- **WireGuard** - VPN de clientes
- **age** - encriptacion (usado por envy)
- **ufw + fail2ban** - firewall y proteccion brute-force

### `envy` (secret manager)

Secrets encriptados con age, separados por contexto (un contexto por cliente).
Los secrets nunca salen de la Pi en texto plano.

```bash
envy-set API_KEY sk-123...     # Guardar secret
envy-get API_KEY               # Leer secret
envy-load                      # Cargar todos como env vars
envy-switch mutt               # Cambiar contexto de cliente
```

### Tailscale (acceso remoto)

Mesh VPN basado en WireGuard. Conecta tus dispositivos como si estuvieran en LAN.

**IP fija de la Pi:** `100.124.229.60`

```bash
# Desde cualquier lugar (iPhone, otra laptop, etc.)
ssh max@100.124.229.60         # O ssh pi-workstation (Magic DNS)
```

**Modos de uso:**

| Modo | Que hace | Cuando usarlo |
|------|----------|---------------|
| Normal | Solo cifra trafico entre tus dispositivos | Uso diario, casa/oficina |
| Exit Node | TODO el trafico sale por la Pi | WiFi publico, red no confiable |

Activar exit node desde iPhone: Tailscale app > Exit Node > pi-workstation.

### tmux (terminal multiplexer)

Las sesiones tmux sobreviven desconexiones. Si se cae el WiFi o cerrás la laptop, la sesion sigue viva en la Pi.

```bash
work connect mutt              # Crear/reconectar sesion "mutt"
# Ctrl+B, d                    # Detach (salir sin cerrar)
work connect mutt              # Volver exactamente donde estabas
```

**Atajos esenciales** (prefijo: `Ctrl+B`):

| Atajo | Accion |
|-------|--------|
| `d` | Detach (salir sin cerrar) |
| `c` | Nueva ventana (pestaña) |
| `n` | Siguiente ventana |
| `"` | Dividir horizontal |
| `%` | Dividir vertical |
| flechas | Moverse entre paneles |

### Chrome aislado (browse)

Cada cliente tiene su propio perfil de Chrome (`~/.chrome-clients/<client>/`).
Cookies, sesiones, historial y extensions completamente separados de tu Chrome personal y entre clientes.

```bash
# Sin VPN: solo perfil aislado (Google Workspace, etc.)
work browse mutt

# Con VPN del cliente activa: trafico ruteado por la Pi
work vpn-up mutt && work browse mutt
```

### SSH hardening

La Pi tiene SSH configurado con las siguientes protecciones:

- **Password auth deshabilitado** - solo SSH keys
- **Root login deshabilitado** - solo user max
- **fail2ban** - bloquea IPs despues de intentos fallidos
- **ufw firewall** - solo puerto 22 abierto
- **MaxAuthTries 3** - maximo 3 intentos por conexion
- **Keepalive** - detecta conexiones muertas

## Setup inicial

### 1. Instalar Raspberry Pi OS Lite (64-bit)

Usar [Raspberry Pi Imager](https://www.raspberrypi.com/software/):
- OS: Raspberry Pi OS Lite (64-bit) -- sin desktop, ahorra RAM
- En settings (gear icon):
  - Hostname: `pi-workstation`
  - Enable SSH (key auth)
  - Set username: `max`
  - Set WiFi (o usar ethernet)

### 2. Copiar SSH key y ejecutar bootstrap

```bash
ssh-copy-id max@pi-workstation.local
scp pi-bootstrap max@pi-workstation.local:~
ssh max@pi-workstation.local ./pi-bootstrap
```

### 3. Clonar repos de config

```bash
# En la Pi:
git clone https://github.com/maxflorentin/dotfiles.git ~/dotfiles
git clone https://github.com/maxflorentin/dotfiles-mbairm4.git ~/.dotfiles
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
```

### 4. Configurar SSH en la Mac

```
# ~/.ssh/config
Host pi-workstation
  HostName 192.168.68.55
  User max
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

### 5. Instalar Tailscale

```bash
# En la Pi:
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh
sudo tailscale set --advertise-exit-node

# En iPhone: instalar Tailscale app, logear con la misma cuenta
# En Mac (opcional): brew install tailscale
```

## Ejemplos de uso

### Dia tipico

```bash
work status                    # Ver que la Pi esta viva
work connect mutt              # Entrar al workspace de mutt
# ... trabajar en nvim, git, docker ...
# Ctrl+B, d                    # Detach cuando termines
```

### Nuevo cliente "acme"

```bash
work setup acme                # Crea workspace + envy context
work connect acme              # Entrar
# git clone <repo-del-cliente>
# envy-set DB_PASSWORD "..."
# envy-load && docker compose up
```

### Acceder a recursos internos del cliente

```bash
# Copiar config WireGuard del cliente a la Pi
scp acme.conf pi-workstation:/tmp/
ssh pi-workstation 'sudo mv /tmp/acme.conf /etc/wireguard/'

# Levantar VPN + Chrome aislado
work vpn-up acme
work browse acme               # Chrome ruteado por la VPN del cliente
# Acceder a Jira, Confluence, dashboards internos, etc.
work vpn-down acme
work browse-stop
```

### Trabajar desde el iPhone (remoto)

```bash
# Abrir Termius/Blink en iPhone
# Conectar a: pi-workstation (o 100.124.229.60)
# User: max (Tailscale SSH maneja la auth)
tmux attach -t mutt            # Reconectar sesion existente
```

### Protegerse en WiFi publico

```
iPhone > Tailscale app > Exit Node > pi-workstation
# Todo el trafico ahora sale cifrado por tu casa
```

### Terminar con un cliente

```bash
work vpn-down acme
work destroy acme              # Borra archivos, secrets, VPN config, tmux session
```

## Archivos

| Archivo | Donde corre | Que hace |
|---------|-------------|----------|
| `pi-bootstrap` | En la Pi | Instala todo el stack |
| `work` | En tu Mac | CLI para gestionar workspaces |
| `~/.dotfiles/` | Ambos | Shell config (aliases, zshrc, starship) |
| `~/dotfiles/` | Ambos | Scripts, envy, nvim config |

## Variables de entorno

| Variable | Default | Descripcion |
|----------|---------|-------------|
| `WORK_PI_HOST` | `pi-workstation` | Hostname de la Pi |
| `WORK_PI_USER` | `max` | Usuario SSH |
| `WORK_PROXY_PORT` | `1080` | Puerto del proxy SOCKS |

## Tips para 4GB RAM

- Raspberry Pi OS **Lite** (sin desktop): ahorra ~500MB
- Docker: 1-2 containers max a la vez
- Node: evitar `npm install` con muchas deps simultaneas
- La Pi ya tiene zram swap configurado por defecto
- Si necesitas mas swap:
  ```bash
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  ```

## Sincronizacion de config

Ambas maquinas comparten config via git. Cuando cambias aliases, zshrc, nvim, etc.:

```bash
# En Mac:
cd ~/.dotfiles && git add -A && git commit -m "update" && git push

# En Pi:
cd ~/.dotfiles && git pull
```
