# Envy - Quick Start

## Setup

```bash
# Initialize (one-time)
envy-init

# Create your contexts
envy-new personal
envy-new work
```

## Add Secrets

```bash
envy-switch work
envy-set API_KEY "xxx"
envy-set SECRET_KEY "xxx"

# Or bulk add from clipboard
envy-add-from-clipboard work API_KEY SECRET_KEY
```

## Load Secrets

```bash
# See what would load
envy-load work

# Actually export to shell
eval "$(envy-load work --export)"

# Verify
echo $API_KEY
```

## Per-project Auto-detect

```bash
# In any project directory
echo "myproject" > .envy-context

# Now just run (no args needed)
eval "$(envy-load --export)"
```

## Aliases

```bash
ev          # envy-list
evl         # envy-load
evs         # envy-set
evg         # envy-get
evrm        # envy-rm
evsw        # envy-switch
```
