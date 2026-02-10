# Migración de KS a Envy

## ✅ Limpieza Completada

- ❌ Eliminado: `zsh/ks-lazy.zsh`
- ❌ Eliminado: Referencias en `.zshrc`
- ❌ Eliminado: Background jobs molestos
- ✅ Mantenido: Comandos básicos de KS (ks-add, ks-get, etc.)

## 🚀 Setup Envy

### 1. Inicializar (YA HECHO)
```bash
# Age ya está instalado y envy inicializado
ls ~/.envy
```

### 2. Crear Contextos

```bash
# Crear contexto personal
envy-new personal

# Crear contexto yuno (trabajo)
envy-new yuno
```

### 3. Migrar Secretos desde KS

```bash
# Migrar secretos personales
envy-migrate-from-ks personal GITHUB_TOKEN

# Migrar secretos de trabajo
envy-migrate-from-ks yuno KINGDOM_TOKEN DD_API_KEY DD_APP_KEY REDASH_API_KEY
```

### 4. Verificar

```bash
# Listar todos los contextos
envy-list

# Ver secretos de un contexto (valores enmascarados)
envy-list personal
envy-list yuno

# Cargar y probar
envy-load personal
echo $GITHUB_TOKEN
```

## 🔧 Uso Diario

### Cargar Contexto en Shell Actual

```bash
# Ver qué se cargaría
envy-load personal

# Cargar en shell actual
eval "$(envy-load personal --export)"

# Verificar
env | grep GITHUB_TOKEN
```

### Agregar Nuevo Secreto

```bash
# Cambiar a contexto deseado
envy-switch yuno

# Agregar secreto
envy-set NEW_API_KEY "xxx-yyy-zzz"

# Verificar
envy-list yuno
```

### Editar Manualmente

```bash
# Abrir en nvim
envy-edit yuno

# Formato:
# KEY=value
# API_KEY=sk-xxx
# DB_PASSWORD=secret123
```

## 🎯 Auto-load en Shell

Agregar a `~/.zshrc` (después de source ALIASES.sh):

```bash
# Auto-load envy context on shell start
if command -v envy-load &> /dev/null; then
    eval "$(envy-load personal --export 2>/dev/null)"
fi
```

## 🔄 Workflows Comunes

### Cambiar de Contexto

```bash
# Trabajo
eval "$(envy-load yuno --export)"

# Personal
eval "$(envy-load personal --export)"
```

### Backup

```bash
# Los archivos .envy.age están encriptados - seguro para backup
cp ~/.envy/*.envy.age ~/Dropbox/backups/

# NUNCA backupear las keys en la nube sin encriptación adicional
# Guardar keys en password manager (1Password, Bitwarden, etc.)
```

### Sincronización entre Máquinas

```bash
# Máquina 1: Exportar key
cat ~/.envy/keys/personal.key
# Copiar contenido a password manager

# Máquina 2: Importar
mkdir -p ~/.envy/keys
cat > ~/.envy/keys/personal.key
# Pegar contenido
chmod 600 ~/.envy/keys/personal.key

# Copiar archivo encriptado
scp user@machine1:~/.envy/personal.envy.age ~/.envy/

# Listo!
envy-load personal
```

## ⚡ Aliases Disponibles

```bash
ev          # envy-list (rápido)
evl         # envy-load
evs         # envy-set
evg         # envy-get
```

## 🗑️ Limpieza de KS (Opcional)

Si ya no usarás KS para estas variables:

```bash
# Ver qué hay en KS
ks -k personal ls
ks -k yuno ls

# Verificar que todo está en envy
envy-list personal
envy-list yuno

# Eliminar de KS (CUIDADO - no hay undo)
# ks -k personal delete GITHUB_TOKEN
# ks -k yuno delete KINGDOM_TOKEN
```

## 💡 Tips

1. **Una key por línea**: `KEY=value` (sin espacios extra)
2. **Sin comillas**: A menos que el valor contenga espacios
3. **Comentarios**: Líneas que empiezan con `#`
4. **Edición rápida**: `envy-edit` abre en nvim
5. **Check status**: `envy-list` muestra valores enmascarados

## 🔒 Seguridad

- ✅ Age usa encriptación moderna (ChaCha20-Poly1305)
- ✅ Keys son de 256 bits
- ✅ Archivos .envy.age son seguros para compartir
- ❌ NUNCA commitear archivos .key a git
- ❌ NUNCA compartir keys sin encriptación adicional

## 🆘 Troubleshooting

### "Context not found"
```bash
envy-list          # Ver contextos disponibles
envy-new <name>    # Crear nuevo
```

### "Permission denied"
```bash
chmod 600 ~/.envy/keys/*.key
chmod 644 ~/.envy/*.envy.age
```

### Corrupción de archivo
```bash
# Los backups automáticos no existen - crear script si lo necesitas
# Por ahora: edita con envy-edit y guarda manualmente
```
