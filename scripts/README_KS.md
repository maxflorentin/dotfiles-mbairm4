# KS Context Management Scripts

Scripts para gestionar múltiples contextos/keychains en `ks` (macOS Keychain Secrets manager).

## Instalación

1. Instalar `ks`:
```bash
brew install ks
```

2. Agregar los aliases a tu `~/.zshrc`:
```bash
source ~/Scripts/dotfiles/ALIASES.sh
```

## Conceptos

- **Contexto**: Un keychain independiente para un proyecto/scope específico (ej: j1, j2, j3, personal)
- **Contexto Activo**: El contexto actual desde el cual se añaden/obtienen secretos
- El contexto activo se guarda en `~/.config/ks/current-context`
- La variable `KS_DEFAULT_KEYCHAIN` se carga automáticamente al iniciar el shell

## Comandos

### Inicializar un nuevo contexto
```bash
ks-init-context <nombre>
# o con alias:
ksi <nombre>

# Ejemplos:
ksi j1
ksi j2
ksi j3
ksi personal
```

### Establecer el contexto activo
```bash
ks-set-context <nombre>
# o con alias:
ksc <nombre>

# Ejemplos:
ksc j1      # Cambiar a contexto j1
ksc personal  # Cambiar a contexto personal
```

### Ver el contexto actual
```bash
ks-get-context
# o con alias:
ksg
```

### Agregar un secreto al contexto actual
```bash
ks-add <key> [value]
# o con alias:
ksa <key> [value]

# Ejemplos:
ksa api-key 'abc123xyz'         # Valor inline
ksa db-password                 # Te pedirá el valor (oculto)
ksa JIRA_TOKEN 'mytoken123'
```

### Obtener un secreto del contexto actual
```bash
ks-get <key>
# o con alias:
ksget <key>

# Ejemplos:
ksget api-key
ksget JIRA_TOKEN

# Usar en scripts:
export API_KEY=$(ksget api-key)
curl -H "Authorization: Bearer $(ksget api-key)" https://api.example.com
```

### Listar todos los secretos del contexto actual
```bash
ks-list
# o con alias:
ksl
```

### Ver todos los contextos disponibles
```bash
ks-contexts
# o con alias:
ksctx
```

## Flujo de Trabajo Típico

### Setup Inicial
```bash
# 1. Inicializar contextos
ksi j1
ksi j2
ksi personal

# 2. Establecer contexto y agregar secretos
ksc j1
ksa JIRA_URL 'https://company1.atlassian.net'
ksa JIRA_EMAIL 'me@company1.com'
ksa JIRA_TOKEN 'token-for-company1'

ksc j2
ksa JIRA_URL 'https://company2.atlassian.net'
ksa JIRA_EMAIL 'me@company2.com'
ksa JIRA_TOKEN 'token-for-company2'
```

### Uso Diario
```bash
# Ver contexto actual
ksg

# Cambiar a proyecto j1
ksc j1

# Usar secretos en scripts
export JIRA_TOKEN=$(ksget JIRA_TOKEN)
./my-jira-script.sh

# Cambiar a proyecto j2
ksc j2
export JIRA_TOKEN=$(ksget JIRA_TOKEN)
./my-jira-script.sh
```

## Integración con Scripts

```bash
#!/bin/bash
# my-api-script.sh

# Los secretos se obtienen automáticamente del contexto actual
API_KEY=$(ksget api-key)
API_URL=$(ksget api-url)

curl -H "Authorization: Bearer ${API_KEY}" "${API_URL}/endpoint"
```

## Sincronización entre Máquinas

Puedes sincronizar tus keychains usando iCloud:

```bash
# En la primera máquina:
cd ~/Library/Keychains
mv ks-j1.keychain ~/Library/Mobile\ Documents/com~apple~CloudDocs/keychains/

# Crear symlink
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/keychains/ks-j1.keychain .

# En otras máquinas, solo crear el symlink:
cd ~/Library/Keychains
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/keychains/ks-j1.keychain .
```

## Aliases Disponibles

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ksc` | `ks-set-context` | Establecer contexto activo |
| `ksg` | `ks-get-context` | Ver contexto actual |
| `ksi` | `ks-init-context` | Inicializar nuevo contexto |
| `ksa` | `ks-add` | Agregar secreto |
| `ksget` | `ks-get` | Obtener secreto |
| `ksl` | `ks-list` | Listar secretos |
| `ksctx` | `ks-contexts` | Ver todos los contextos |

## Ejemplo Completo: Integración con JIRA

Mira el script de ejemplo `ks-example-jira.sh` que demuestra cómo usar los secretos del contexto actual:

```bash
# 1. Configurar secretos de JIRA para cada cliente
ksc j1
ksa JIRA_URL 'https://client1.atlassian.net'
ksa JIRA_EMAIL 'me@client1.com'
ksa JIRA_TOKEN 'token1'

ksc j2
ksa JIRA_URL 'https://client2.atlassian.net'
ksa JIRA_EMAIL 'me@client2.com'
ksa JIRA_TOKEN 'token2'

# 2. Cambiar de contexto y usar el script
ksc j1
./ks-example-jira.sh  # Usa secretos de client1

ksc j2
./ks-example-jira.sh  # Usa secretos de client2
```

## Comandos Make Disponibles

También puedes usar el Makefile:

```bash
# Inicializar contexto
make ks-init CONTEXT=j1

# Establecer contexto
make ks-set CONTEXT=j1

# Ver contexto actual
make ks-context

# Agregar secreto
make ks-add KEY=api-key VALUE='abc123'

# Obtener secreto
make ks-get KEY=api-key

# Listar secretos
make ks-list

# Ver ayuda
make ks-help
```

## Casos de Uso Avanzados

### Almacenar múltiples líneas (ej: Recovery Codes)

`ks` puede almacenar cadenas con saltos de línea sin problemas. Esto es ideal para los recovery codes de GitHub.

#### Opción 1: Desde un archivo (Recomendado)
Si tienes tus códigos en un archivo `codes.txt`:
```bash
ksa -f codes.txt github-recovery
```

#### Opción 2: Interactiva (Pegar bloque)
Si ejecutas `ksa` sin el valor:
```bash
ksa github-recovery
```
Te pedirá el valor. Puedes pegar el bloque completo de códigos y presionar `Enter` (si el script maneja stdin correctamente) o usar el comando anterior para mayor seguridad.

### Recuperar códigos
```bash
ksget github-recovery
```

## Tips

1. **Auto-carga del contexto**: El contexto se carga automáticamente al abrir un nuevo terminal
2. **Scripts portables**: Usa `ksget` en tus scripts para que funcionen con cualquier contexto
3. **Proyectos múltiples**: Cambia de contexto según el proyecto en el que trabajes
4. **Seguridad**: Los secretos están encriptados en el Keychain de macOS
5. **Nombres consistentes**: Usa los mismos nombres de keys en todos los contextos (ej: JIRA_TOKEN) para que tus scripts sean portables
6. **Variables de entorno**: Exporta secretos como variables de entorno para usarlos en múltiples comandos
