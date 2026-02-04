# KS Context Management - Quick Start

## 1. Setup Inicial (solo una vez)

```bash
# Agregar aliases a tu .zshrc
echo 'source ~/Scripts/dotfiles/ALIASES.sh' >> ~/.zshrc

# Recargar terminal
source ~/.zshrc
```

## 2. Crear tus contextos

```bash
# Inicializar contextos para cada cliente/proyecto
ksi j1
ksi j2
ksi j3
ksi personal
```

## 3. Configurar secretos

```bash
# Contexto J1
ksc j1
ksa JIRA_URL 'https://client1.atlassian.net'
ksa JIRA_EMAIL 'tu-email@client1.com'
ksa JIRA_TOKEN  # Te pedirá el token (oculto)

# Contexto J2
ksc j2
ksa JIRA_URL 'https://client2.atlassian.net'
ksa JIRA_EMAIL 'tu-email@client2.com'
ksa JIRA_TOKEN

# Contexto Personal
ksc personal
ksa GITHUB_TOKEN
ksa AWS_ACCESS_KEY
```

## 4. Uso Diario

```bash
# Ver todos los contextos
ksctx

# Cambiar a un proyecto
ksc j1

# Ver contexto actual
ksg

# Listar secretos
ksl

# Usar secretos en comandos
export JIRA_TOKEN=$(ksget JIRA_TOKEN)
./mi-script.sh

# Cambiar a otro proyecto
ksc j2
./mismo-script.sh  # Ahora usa secretos de j2
```

## 5. Integración en Scripts

```bash
#!/bin/bash
# mi-script.sh

# Los secretos se obtienen del contexto actual
API_KEY=$(ksget api-key)
API_URL=$(ksget api-url)

curl -H "Authorization: Bearer ${API_KEY}" "${API_URL}/endpoint"
```

## Comandos Más Usados

```bash
ksc j1           # Cambiar a contexto j1
ksg              # Ver contexto actual
ksa key value    # Agregar secreto
ksget key        # Obtener secreto
ksl              # Listar secretos
ksctx            # Ver todos los contextos
```

## Variables Recomendadas por Contexto

### Para JIRA
- `JIRA_URL`
- `JIRA_EMAIL`
- `JIRA_TOKEN`
- `JIRA_PROJECT`

### Para APIs
- `API_KEY`
- `API_SECRET`
- `API_URL`

### Para Bases de Datos
- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`

### Para AWS
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Sincronización entre Máquinas (Opcional)

### Automático con scripts

```bash
# En el primer dispositivo
ksi j1
ksc j1
ksa JIRA_TOKEN 'mi-token'

# Habilitar iCloud sync
ks-sync-enable j1

# En otros Macs (después de que iCloud sincronice)
ks-sync-link j1

# Verificar estado
ks-sync-status
```

Ver [README_KS_SYNC.md](README_KS_SYNC.md) para más detalles.

## Troubleshooting

### "No context set"
```bash
# Lista contextos disponibles
ksctx

# Establece uno
ksc j1
```

### "Context mismatch"
```bash
# Recargar variable de entorno
export KS_DEFAULT_KEYCHAIN=$(cat ~/.config/ks/current-context)

# O establecer manualmente
export KS_DEFAULT_KEYCHAIN=j1
```

### Ver más ayuda
```bash
cat ~/Scripts/dotfiles/README_KS.md
make ks-help
```
