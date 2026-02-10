# Envy - Quick Start

## 5 Minutos para Empezar

### 1️⃣ Ya está inicializado! ✅

```bash
ls ~/.envy
# Deberías ver: keys/, config, README.md, .gitignore
```

### 2️⃣ Crear tu primer contexto

```bash
cd ~/projects/dotfiles/scripts/envy
./envy-new personal
```

### 3️⃣ Migrar tus secretos de KS

```bash
# Personal
./envy-migrate-from-ks personal GITHUB_TOKEN

# Trabajo
./envy-migrate-from-ks yuno KINGDOM_TOKEN DD_API_KEY DD_APP_KEY REDASH_API_KEY
```

### 4️⃣ Cargar en tu shell

```bash
# Ver qué hay
./envy-list

# Cargar en shell actual
eval "$(./envy-load personal --export)"

# Verificar
echo $GITHUB_TOKEN
```

### 5️⃣ Auto-load en futuras sesiones

Agregar a `~/.zshrc`:

```bash
# Envy auto-load
if [ -f "$HOME/projects/dotfiles/scripts/envy/envy-load" ]; then
    eval "$($HOME/projects/dotfiles/scripts/envy/envy-load personal --export 2>/dev/null)"
fi
```

## 🎉 Listo!

- ✅ Sin subshells molestos
- ✅ Sin prompts de contraseña
- ✅ Carga instantánea
- ✅ Archivos encriptados
- ✅ Multi-contexto

## Comandos más usados

```bash
cd ~/projects/dotfiles/scripts/envy

./envy-list                              # Ver todo
./envy-list personal                     # Ver contexto específico
./envy-set API_KEY "xxx"                 # Agregar secreto
eval "$(./envy-load yuno --export)"      # Cargar contexto
./envy-edit                              # Editar manualmente
```

## Próximos pasos

- Lee `MIGRATION.md` para detalles completos
- Lee `README.md` para documentación extensa
- Configura auto-load en `.zshrc`
- Backup de tus keys (password manager!)

---

**Nota**: Los comandos ya están en PATH después de `source ~/.zshrc`.
Puedes usar `envy-list` directamente sin el `./`
