# Pi 400 Workstation - Freelance Isolation

Raspberry Pi 400 como dev server aislado para trabajo freelance.
El cliente ve la Pi. Tu Mac queda intocable.

## Arquitectura

```
Mac (personal)                    Pi 400 (clientes)
├── SSH ──────────────────────>   ├── ~/clients/acme/
│                                 │   ├── .envy-context
│                                 │   └── (proyecto)
│                                 ├── VPN del cliente
│                                 ├── Software monitoreo
│                                 └── nvim + node + python + docker
```

## Setup inicial

### 1. Instalar Raspberry Pi OS Lite (64-bit)

Usar [Raspberry Pi Imager](https://www.raspberrypi.com/software/):
- OS: Raspberry Pi OS Lite (64-bit) -- sin desktop, ahorra RAM
- En settings (gear icon):
  - Hostname: `pi`
  - Enable SSH (key auth)
  - Set username: `max`
  - Set WiFi (o usar ethernet)

### 2. Copiar tu SSH key a la Pi

```bash
ssh-copy-id max@pi.local
```

### 3. Ejecutar bootstrap

```bash
scp pi-bootstrap max@pi.local:~
ssh max@pi.local ./pi-bootstrap
```

Esto instala: nvim, node, python, docker, git, age, starship, tmux, zsh, wireguard, y tu dotfiles.

### 4. Inicializar envy en la Pi

```bash
ssh max@pi.local
envy-init
envy-new personal  # si necesitas secrets personales ahi
```

## Uso diario

### Nuevo cliente

```bash
work setup acme
```

Crea `~/clients/acme/` con `.envy-context` y un envy context en la Pi.

### Conectar

```bash
work connect acme       # SSH + tmux, sesion "acme"
work connect            # SSH + tmux, sesion "main"
```

Detach con `Ctrl+B, D`. La sesion queda viva.

### Sincronizar codigo

```bash
work sync acme ./mi-proyecto   # rsync local -> Pi
```

### VPN del cliente

```bash
# Primero: copiar config WireGuard a la Pi
scp acme.conf max@pi.local:/tmp/
ssh max@pi.local 'sudo mv /tmp/acme.conf /etc/wireguard/'

# Luego:
work vpn-up acme
work vpn-down acme
```

Para OpenVPN, instalar en la Pi y correr manualmente.

### Estado

```bash
work status     # RAM, docker, VPNs, sesiones, clientes
```

### Terminar con un cliente

```bash
work destroy acme   # Borra todo: archivos, secrets, VPN config
```

## Tips para 4GB RAM

- Usar Raspberry Pi OS **Lite** (sin desktop): ahorra ~500MB
- Docker: 1-2 containers max a la vez
- Node: evitar `npm install` con muchas deps simultaneas
- Si necesitas mas RAM: agregar swap (2GB file)
  ```bash
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  ```

## Archivos

| Archivo | Donde corre | Que hace |
|---------|-------------|----------|
| `pi-bootstrap` | En la Pi | Instala todo el stack |
| `work` | En tu Mac | Gestiona workspaces (connect/setup/sync/vpn/destroy) |

## Variables de entorno

| Variable | Default | Descripcion |
|----------|---------|-------------|
| `WORK_PI_HOST` | `pi-workstation` | Hostname de la Pi |
| `WORK_PI_USER` | `max` | Usuario SSH |
