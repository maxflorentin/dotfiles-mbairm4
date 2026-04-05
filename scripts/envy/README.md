# Envy - Encrypted Environment Manager

Simple, fast secret management using [age](https://github.com/FiloSottile/age) encryption.

## Structure

```
~/.envy/
├── keys/
│   ├── personal.key      # Age keys (NEVER commit these)
│   └── work.key
├── personal.envy.age     # Encrypted secrets
├── work.envy.age
└── config                # Current context
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `envy-load <context>` | `evl` | Load context (export all variables) |
| `envy-set <KEY> <value>` | `evs` | Add/update secret in current context |
| `envy-get <KEY>` | `evg` | Get secret from current context |
| `envy-list` | `ev` | List all contexts and variables |
| `envy-switch <context>` | `evsw` | Switch to different context |
| `envy-rm <KEY>` | `evrm` | Remove a secret |
| `envy-new <context>` | | Create new context with encryption key |
| `envy-edit` | | Edit current context in $EDITOR |
| `envy-clear <context>` | | Remove ALL secrets from a context |
| `envy-rename-context` | | Rename a context |

## Scopes

Envy supports multiple contexts (scopes) for organizing secrets:

- **personal** - Personal tokens (GitHub, OpenAI, etc.)
- **work** - Work-related secrets
- **\<project\>** - Per-project secrets (any name)

### Auto-detect by directory

Place a `.envy-context` file in your project root:

```bash
echo "myproject" > ~/projects/myapp/.envy-context
```

Now `envy-load` (or `evl`) without arguments will automatically detect the context when you're inside that directory. It walks up parent directories until it finds `.envy-context`, then falls back to `~/.envy/config`.

## Usage

```bash
# Create contexts
envy-new personal
envy-new work

# Add secrets
envy-switch work
envy-set API_KEY "xxx"
envy-set SECRET_KEY "xxx"

# Load in current shell
eval "$(envy-load work --export)"

# List everything
envy-list

# Edit secrets manually
envy-edit
```

## Shell Integration

Already configured via `aliases.zsh`. To auto-load on shell start, add to `~/.zshrc`:

```bash
if command -v envy-load &> /dev/null; then
    eval "$(envy-load personal --export 2>/dev/null)"
fi
```

## iCloud Sync

```bash
envy-setup-icloud
```

Moves `~/.envy` to iCloud Drive with a symlink for compatibility.

## Security

- **Keys** (`~/.envy/keys/`) - NEVER commit or share
- **Encrypted files** (`.envy.age`) - Safe to backup/sync
- Age uses ChaCha20-Poly1305 with 256-bit keys
