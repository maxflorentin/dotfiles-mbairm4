# 🚀 Migration Guide: KS → Envy (iCloud Sync)

## Problem with KS
- Asks for password 20+ times per session 😤
- macOS Keychain prompts are annoying
- `ks-trust-setup` doesn't help enough

## Solution: Envy
- **Zero password prompts** (uses key files, not interactive passwords)
- **iCloud sync** across all your devices
- **Age encryption** (modern, secure)
- **Faster** than KS

---

## 📋 Migration Steps

### Step 1: Setup Envy with iCloud

```bash
cd ~/projects/dotfiles/scripts

# Move envy to iCloud (enables automatic sync)
./envy-setup-icloud
```

This will:
- Move `~/.envy` to iCloud Drive
- Create symlink for compatibility
- Enable automatic sync across devices

### Step 2: List Your Current KS Secrets

```bash
# Check what you have in KS
ks -k personal ls
ks -k yuno ls
```

**Expected output:**
```
Personal secrets:
- GITHUB_TOKEN
- OPENAI_API_KEY
- ...

Yuno secrets:
- KINGDOM_TOKEN
- DD_API_KEY
- DD_APP_KEY
- ...
```

### Step 3: Migrate Secrets

```bash
# Migrate personal secrets (replace with your actual keys)
./envy/envy-migrate-from-ks personal GITHUB_TOKEN OPENAI_API_KEY

# Migrate work secrets
./envy/envy-migrate-from-ks yuno KINGDOM_TOKEN DD_API_KEY DD_APP_KEY REDASH_API_KEY
```

⚠️ **IMPORTANT:** You'll be asked for KS passwords ONE LAST TIME during migration.

### Step 4: Verify Migration

```bash
# List contexts
envy-list

# Test loading personal context
envy-load personal
echo $GITHUB_TOKEN    # Should show your token

# Test loading yuno context
envy-load yuno
echo $KINGDOM_TOKEN   # Should show your token
```

### Step 5: Update Your Shell

Already configured in `ALIASES.sh`! Just reload:

```bash
source ~/projects/dotfiles/scripts/ALIASES.sh

# Or restart terminal
```

---

## 🎯 Daily Usage

### Load Context (replaces ks commands)

```bash
# Load personal secrets
evl personal          # or: envy-load personal

# Load work secrets
evl yuno             # or: envy-load yuno

# Quick list all
ev                   # or: envy-list
```

### Add New Secret

```bash
# Switch context first
envy-switch personal

# Add secret
evs GITHUB_TOKEN "ghp_xxx..."    # or: envy-set
evs NEW_API_KEY "sk-xxx..."

# Verify
ev
```

### Get Specific Secret

```bash
evg GITHUB_TOKEN     # or: envy-get GITHUB_TOKEN

# Copy to clipboard
evg GITHUB_TOKEN | pbcopy
```

---

## 🔄 Sync Across Devices

### On Your Other Mac/Device:

1. Wait for iCloud to sync
2. Run the setup script:
   ```bash
   cd ~/projects/dotfiles/scripts
   ./envy-setup-icloud
   ```
3. Done! All your secrets are available

**Note:** The script will detect iCloud files and create the symlink automatically.

---

## 🗑️ Optional: Cleanup KS

Once you've verified everything works:

```bash
# CAREFUL - No undo!
# Delete secrets from KS (one by one)
ks -k personal rm GITHUB_TOKEN
ks -k yuno rm KINGDOM_TOKEN

# Or remove entire keychain contexts
# (only if you're 100% sure!)
```

---

## 🆚 Comparison: KS vs Envy

| Feature | KS (old) | Envy (new) |
|---------|----------|------------|
| Password prompts | 20+ per session 😤 | **0** ✨ |
| Encryption | macOS Keychain | Age (ChaCha20) |
| Sync | iCloud (keychain) | **iCloud (files)** |
| Speed | Slow | **Fast** |
| Cross-platform | macOS only | **Any OS** |
| Setup complexity | Medium | **Simple** |

---

## 🔒 Security Notes

### What's in iCloud:
- `*.envy.age` - **Encrypted secrets** (safe to sync)
- `keys/*.key` - **Private keys** (convenient but consider 1Password)

### Best Practices:
1. **Encrypted files are safe** - Can't be read without private key
2. **Keys in iCloud** - Convenient but adds risk
3. **Consider 1Password** - Store keys there for max security
4. **Enable 2FA on iCloud** - Protect your Apple ID

### Extra Security Option:

Store keys in 1Password instead of iCloud:

```bash
# Save key to 1Password
cat ~/.envy/keys/personal.key
# Copy to 1Password secure note

# Remove from iCloud (keys only, keep .envy.age files)
rm ~/.envy/keys/*.key

# Restore when needed
cat > ~/.envy/keys/personal.key
# Paste from 1Password
```

---

## ❓ Troubleshooting

### "Context not found"

```bash
envy-new personal
envy-new yuno
```

### "Permission denied"

```bash
chmod 600 ~/.envy/keys/*.key
chmod 644 ~/.envy/*.envy.age
```

### Still seeing KS password prompts?

Make sure you're using envy commands:
- ✅ `evl personal` (envy)
- ❌ `ks-get GITHUB_TOKEN` (old KS)

---

## 📚 Quick Reference

```bash
# Envy commands (aliases)
ev          # List all contexts
evl         # Load context
evs         # Set secret
evg         # Get secret

# Full commands
envy-list
envy-load <context>
envy-set <KEY> <value>
envy-get <KEY>
envy-switch <context>
envy-edit              # Edit in nvim
envy-new <context>     # Create new context
```

---

## ✅ Success Checklist

- [ ] Ran `envy-setup-icloud`
- [ ] Migrated secrets from KS
- [ ] Verified with `envy-load personal`
- [ ] Verified with `envy-load yuno`
- [ ] Tested on another device (optional)
- [ ] No more password prompts! 🎉

---

**Questions?** Check the README in `~/.envy/README.md`
