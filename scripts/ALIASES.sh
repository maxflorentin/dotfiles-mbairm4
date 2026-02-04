# Jira Automation Scripts Aliases
# Add these to your ~/.zshrc

alias jira-fields='~/Scripts/dotfiles/jira_get_fields.py'
alias jira-create='~/Scripts/dotfiles/jira_create_ticket.py'
alias jira-md2adf='~/Scripts/dotfiles/markdown_to_jira_adf.py'
alias jira-merge='~/Scripts/dotfiles/jira_merge_json.py'

# KS (Keychain Secrets) Context Management
# Auto-load current context on shell start
export KS_DEFAULT_KEYCHAIN=$(cat ~/.config/ks/current-context 2>/dev/null || echo 'personal')

alias ksc='ks-set-context'
alias ksg='ks-get-context'
alias ksi='ks-init-context'
alias ksa='ks-add'
alias ksget='ks-get'
alias ksl='ks-list'
alias ksctx='ks-contexts'

# KS iCloud Sync
alias ks-sync='ks-sync-status'
alias ks-enable-sync='ks-sync-enable'
alias ks-link-sync='ks-sync-link'
