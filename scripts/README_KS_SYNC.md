# KS iCloud Sync - Compartir Keychains entre Dispositivos

Guía para sincronizar tus keychains de `ks` entre múltiples Macs usando iCloud Drive.

## Cómo Funciona

Los keychains se almacenan normalmente en `~/Library/Keychains/`. Para sincronizarlos:

1. Se mueven a `~/Library/Mobile Documents/com~apple~CloudDocs/keychains/` (iCloud)
2. Se crea un symlink desde la ubicación original
3. iCloud Drive sincroniza automáticamente el archivo
4. En otros dispositivos, se crea el symlink apuntando al archivo en iCloud

## Setup: Dispositivo Principal

```bash
# 1. Crear el contexto normalmente
ksi j1

# 2. Agregar secretos
ksc j1
ksa JIRA_TOKEN 'mi-token'
ksa API_KEY 'mi-key'

# 3. Habilitar sincronización a iCloud
ks-sync-enable j1
```

El script:
- Mueve el keychain a iCloud Drive
- Crea un symlink local
- Espera a que iCloud lo sincronice

## Setup: Otros Dispositivos

Una vez que iCloud ha sincronizado el archivo:

```bash
# En tu segundo Mac, simplemente vincula el keychain
ks-sync-link j1

# Ahora puedes usarlo
ksc j1
ksget JIRA_TOKEN  # Funciona!
```

## Verificar Estado de Sincronización

```bash
# Ver estado de todos los keychains
ks-sync-status

# Salida ejemplo:
# Keychain Sync Status
# ====================
#
# Local Keychains:
#   ✓ j1 (synced to iCloud)
#   ✓ j2 (synced to iCloud)
#   ○ personal (local only)
#
# iCloud Keychains:
#   ✓ j1 (linked locally)
#   ✓ j2 (linked locally)
```

## Flujo de Trabajo Completo

### En el primer dispositivo (MacBook principal):

```bash
# Crear y configurar contextos
ksi j1
ksi j2
ksi personal

# Agregar secretos
ksc j1
ksa JIRA_URL 'https://client1.atlassian.net'
ksa JIRA_EMAIL 'me@client1.com'
ksa JIRA_TOKEN

ksc j2
ksa JIRA_URL 'https://client2.atlassian.net'
ksa JIRA_EMAIL 'me@client2.com'
ksa JIRA_TOKEN

# Habilitar sync para contextos compartidos
ks-sync-enable j1
ks-sync-enable j2

# Personal se queda solo en este dispositivo (no sincronizar)
```

### En el segundo dispositivo (iMac/otro Mac):

```bash
# Esperar a que iCloud sincronice (unos minutos)

# Verificar qué está disponible
ks-sync-status

# Vincular los contextos sincronizados
ks-sync-link j1
ks-sync-link j2

# Crear contextos locales si es necesario
ksi personal-work-mac
ksc personal-work-mac
ksa LOCAL_SECRET 'algo-solo-aqui'
```

### Uso diario (en cualquier dispositivo):

```bash
# Cambiar de contexto
ksc j1

# Los secretos están sincronizados!
ksget JIRA_TOKEN

# Cambios se sincronizan automáticamente
ksa NEW_SECRET 'valor'  # Se sincroniza a otros dispositivos
```

## Comandos de Sincronización

| Comando | Descripción |
|---------|-------------|
| `ks-sync-status` | Ver estado de sync de todos los keychains |
| `ks-sync-enable <context>` | Mover keychain a iCloud (primer dispositivo) |
| `ks-sync-link <context>` | Vincular a keychain en iCloud (otros dispositivos) |

### Aliases

| Alias | Comando |
|-------|---------|
| `ks-sync` | `ks-sync-status` |
| `ks-enable-sync` | `ks-sync-enable` |
| `ks-link-sync` | `ks-sync-link` |

## Consideraciones de Seguridad

### Pros
- Los keychains están encriptados por macOS Keychain
- Solo accesibles con tu contraseña/Touch ID
- iCloud usa encriptación en tránsito y en reposo

### Contras
- Los keychains sincronizados están en iCloud (cloud storage)
- Accesibles desde cualquier Mac con tu cuenta de iCloud
- Si prefieres máxima seguridad, no sincronices secretos críticos

### Recomendaciones

```bash
# Sincronizar: tokens de APIs, credenciales de desarrollo
ks-sync-enable j1-dev
ks-sync-enable j2-dev

# NO sincronizar: claves privadas SSH, credenciales de producción
# (mantenerlos como local only)
ksi production-secrets  # Sin ks-sync-enable
```

## Troubleshooting

### "Keychain not found in iCloud"

```bash
# Verificar que iCloud Drive está habilitado
open ~/Library/Mobile\ Documents/com~apple~CloudDocs/

# Verificar el estado
ks-sync-status

# Forzar sync de iCloud (en el primer dispositivo)
# System Settings > iCloud > iCloud Drive > Options
```

### "Already synced"

```bash
# Si intentas sync algo ya sincronizado
ks-sync-status  # Ver estado actual
```

### Conflictos

Si modificas secretos simultáneamente en dos dispositivos:
- iCloud sincronizará el último cambio
- Considera establecer un dispositivo "principal" para cambios

### Restaurar backup local

```bash
# Si ks-sync-link hizo backup
ls ~/Library/Keychains/ks-*.local-backup

# Restaurar si es necesario
cd ~/Library/Keychains
rm ks-j1.keychain
mv ks-j1.keychain.local-backup ks-j1.keychain
```

## Tips

1. **Nomenclatura**: Usa nombres descriptivos
   - `company1-prod`, `company1-dev` en vez de `j1`, `j2`

2. **Contextos locales**: No todos necesitan sincronizarse
   - Personal secrets: local only
   - Shared work secrets: sync

3. **Verificación**: Después de vincular, verifica
   ```bash
   ksc j1
   ksl  # Deberías ver los secretos
   ```

4. **Primer sync**: Puede tomar unos minutos
   - Espera a que iCloud termine de subir
   - Verifica en Finder que el archivo existe en iCloud

5. **Performance**: Los symlinks no afectan performance
   - `ks` funciona igual de rápido

## Ejemplos de Uso

### Desarrollador Freelance

```bash
# MacBook Pro (principal)
ksi client-a
ksi client-b
ksi client-c
ks-sync-enable client-a
ks-sync-enable client-b
ks-sync-enable client-c

# iMac en casa
ks-sync-link client-a
ks-sync-link client-b
ks-sync-link client-c

# Ahora trabajas desde cualquier Mac con los mismos secretos
```

### Equipo con múltiples proyectos

```bash
# Cada miembro:
# 1. Recibe contextos compartidos via export/import
# 2. Configura sus propios keychains locales
# 3. Sincroniza solo lo necesario

# Líder técnico comparte estructura:
ks-sync-enable team-staging
ks-sync-enable team-dev

# Miembros vinculan:
ks-sync-link team-staging
ks-sync-link team-dev

# Cada uno tiene contextos privados no sincronizados
ksi my-personal
```
