# Jira Automation Scripts Aliases
# Add these to your ~/.zshrc

alias jira-fields='~/Scripts/dotfiles/jira_get_fields.py'
alias jira-create='~/Scripts/dotfiles/jira_create_ticket.py'
alias jira-md2adf='~/Scripts/dotfiles/markdown_to_jira_adf.py'
alias jira-merge='~/Scripts/dotfiles/jira_merge_json.py'

# Patent Verification
alias patent='~/projects/dotfiles/scripts/patent_verifier.py'

# KS (Keychain Secrets) Context Management
# Auto-load current context on shell start
export KS_DEFAULT_KEYCHAIN=$(cat ~/.config/ks/current-context 2>/dev/null || echo 'personal')

alias ksc='ks-set-context'
alias ksg='ks-get-context'
alias ksi='ks-init-context'
alias ksa='ks-add'
alias ksget='ks-get'
alias kscp='ks-cp'
alias ksl='ks-list'
alias ksctx='ks-contexts'

# KS iCloud Sync
alias ks-sync='ks-sync-status'
alias ks-enable-sync='ks-sync-enable'
alias ks-link-sync='ks-sync-link'

# KS Trust Setup (reduce password prompts)
alias ks-trust='ks-trust-setup'

# ==========================================
# ENVY - Modern Encrypted Secret Manager
# ==========================================
# Add envy scripts to PATH
export PATH="$HOME/projects/dotfiles/scripts/envy:$PATH"

# Envy shortcuts (optional - scripts are already in PATH)
alias ev='envy-list'     # Quick list
alias evl='envy-load'    # Quick load
alias evs='envy-set'     # Quick set
alias evg='envy-get'     # Quick get
alias evrm='envy-rm'     # Quick remove
alias evsw='envy-switch' # Quick switch context

alias clau='claude'
