# Envy - Simple Encrypted Environment Manager

Modern replacement for ks-lazy with clean, simple secret management.

## Features

- 🔐 **Age encryption** - Military-grade encryption for your secrets
- 🎯 **Multiple contexts** - Separate environments (personal, work, projects)
- 🚀 **Zero startup delay** - No background jobs or subshells
- 🧹 **Clean integration** - Simple key=value syntax
- 🔄 **Easy migration** - Import from ks with one command

## Structure

```
~/.envy/
├── keys/
│   ├── personal.key      # Age keys (NEVER commit these)
│   └── yuno.key
├── personal.envy.age     # Encrypted secrets
├── yuno.envy.age
└── config                # Current context
```

## Installation

```bash
# 1. Install age encryption
brew install age

# 2. Initialize envy
envy-init

# 3. Create a context
envy-new personal

# 4. Add secrets
envy-set GITHUB_TOKEN "ghp_xxx..."
envy-set OPENAI_API_KEY "sk-xxx..."

# 5. Load context (exports variables to current shell)
envy-load personal
```

## Commands

| Command | Description |
|---------|-------------|
| `envy-init` | Initialize envy (install dependencies, create structure) |
| `envy-new <context>` | Create new context with encryption key |
| `envy-set <KEY> <value>` | Add/update secret in current context |
| `envy-get <KEY>` | Get secret from current context |
| `envy-load <context>` | Load context (export all variables) |
| `envy-list` | List all contexts and variables |
| `envy-edit` | Edit current context (opens in $EDITOR) |
| `envy-switch <context>` | Switch to different context |
| `envy-migrate-from-ks` | Import secrets from KS |

## Usage Examples

```bash
# Create work context
envy-new yuno
envy-set KINGDOM_TOKEN "xxx"
envy-set DD_API_KEY "xxx"
envy-set DD_APP_KEY "xxx"

# Switch contexts
envy-load yuno        # Load work secrets
envy-load personal    # Switch to personal

# Check what's loaded
envy-list

# Edit secrets manually
envy-edit
```

## Migration from KS

```bash
# Automatic migration
envy-migrate-from-ks personal GITHUB_TOKEN
envy-migrate-from-ks yuno KINGDOM_TOKEN DD_API_KEY DD_APP_KEY

# Verify
envy-load personal
echo $GITHUB_TOKEN
```

## Integration with .zshrc

Add to your `~/.zshrc`:

```bash
# Load default envy context
ENVY_DEFAULT_CONTEXT="personal"
if command -v envy-load &> /dev/null; then
    eval "$(envy-load $ENVY_DEFAULT_CONTEXT --export)"
fi
```

## Security Notes

- **Keys are stored in `~/.envy/keys/`** - Keep these safe!
- **Never commit `.key` files** - Add to `.gitignore`
- **Encrypted files (.envy.age)** - Safe to backup/sync
- **Use strong passphrases** - Consider using age with passphrase encryption

## vs KS (Keychain Secrets)

| Feature | envy | ks |
|---------|------|-----|
| Encryption | age (file-based) | macOS Keychain |
| Startup time | Instant | Background jobs |
| Password prompts | Once per key | Frequent |
| Cross-platform | Yes | macOS only |
| Backup | Easy (encrypted files) | iCloud sync |
| Simplicity | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
