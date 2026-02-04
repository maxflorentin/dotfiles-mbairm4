# Define the scripts directory in HOME
SCRIPTS_DIR := $(HOME)/Scripts/dotfiles

# Define where the scripts are stored within your repo
REPO_SCRIPTS_DIR := $(CURDIR)

.PHONY: backup
backup:
	@echo "Backing up Scripts..."
	@echo "Note: Scripts are managed in the repo, no backup needed."

.PHONY: link
link:
	@echo "Creating symlinks for Scripts..."
	# Check if the Scripts/dotfiles directory already exists
	@if [ -d "$(SCRIPTS_DIR)" ] && [ ! -L "$(SCRIPTS_DIR)" ]; then \
		echo "Moving existing Scripts/dotfiles to $(HOME)/Scripts/dotfiles.bak"; \
		mv $(SCRIPTS_DIR) $(HOME)/Scripts/dotfiles.bak; \
	fi
	# Ensure the parent directory (~/Scripts) exists
	@mkdir -p $(dir $(SCRIPTS_DIR))
	# Create the symbolic link:
	# -s: create a symbolic link
	# -f: force (remove existing destination files)
	# -n: treat destination as a normal file if it's a directory
	@ln -sfn $(REPO_SCRIPTS_DIR) $(SCRIPTS_DIR)
	@echo "Scripts symlink created successfully."

.PHONY: clean
clean:
	@echo "Removing Scripts symlink..."
	@rm -f $(SCRIPTS_DIR)
	@echo "Restoring backup if it exists..."
	@if [ -d "$(HOME)/Scripts/dotfiles.bak" ]; then \
		mv $(HOME)/Scripts/dotfiles.bak $(SCRIPTS_DIR); \
		echo "Scripts restored from backup."; \
	else \
		echo "No Scripts backup found to restore."; \
	fi

.PHONY: jira-fields
jira-fields:
	@$(REPO_SCRIPTS_DIR)/jira_get_fields.py

.PHONY: jira-create
jira-create:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make jira-create FILE=ticket.json"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/jira_create_ticket.py $(FILE)

.PHONY: md-to-adf
md-to-adf:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make md-to-adf FILE=description.md"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/markdown_to_jira_adf.py $(FILE)

.PHONY: jira-merge
jira-merge:
	@if [ -z "$(TEMPLATE)" ] || [ -z "$(MD)" ]; then \
		echo "Usage: make jira-merge TEMPLATE=template.json MD=desc.md [OUTPUT=ticket.json]"; \
		exit 1; \
	fi
	@if [ -n "$(OUTPUT)" ]; then \
		$(REPO_SCRIPTS_DIR)/jira_merge_json.py -t $(TEMPLATE) -m $(MD) -o $(OUTPUT); \
	else \
		$(REPO_SCRIPTS_DIR)/jira_merge_json.py -t $(TEMPLATE) -m $(MD); \
	fi

.PHONY: jira-help
jira-help:
	@echo "Jira Automation Commands:"
	@echo "  make jira-fields                           - Get all available Jira fields"
	@echo "  make jira-create FILE=ticket.json          - Create ticket from JSON"
	@echo "  make md-to-adf FILE=desc.md                - Convert markdown to ADF"
	@echo "  make jira-merge TEMPLATE=t.json MD=d.md    - Merge markdown into template"
	@echo ""
	@echo "Examples:"
	@echo "  make jira-merge TEMPLATE=jira_ticket_template.json MD=my_desc.md OUTPUT=final.json"
	@echo "  make jira-create FILE=final.json"

# KS Context Management
.PHONY: ks-init
ks-init:
	@if [ -z "$(CONTEXT)" ]; then \
		echo "Usage: make ks-init CONTEXT=<name>"; \
		echo "Examples: make ks-init CONTEXT=j1"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/ks-init-context $(CONTEXT)

.PHONY: ks-set
ks-set:
	@if [ -z "$(CONTEXT)" ]; then \
		echo "Usage: make ks-set CONTEXT=<name>"; \
		echo "Examples: make ks-set CONTEXT=j1"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/ks-set-context $(CONTEXT)

.PHONY: ks-context
ks-context:
	@$(REPO_SCRIPTS_DIR)/ks-get-context

.PHONY: ks-add
ks-add:
	@if [ -z "$(KEY)" ]; then \
		echo "Usage: make ks-add KEY=<key> [VALUE=<value>]"; \
		echo "Examples: make ks-add KEY=api-key VALUE='abc123'"; \
		exit 1; \
	fi
	@if [ -n "$(VALUE)" ]; then \
		$(REPO_SCRIPTS_DIR)/ks-add $(KEY) $(VALUE); \
	else \
		$(REPO_SCRIPTS_DIR)/ks-add $(KEY); \
	fi

.PHONY: ks-get
ks-get:
	@if [ -z "$(KEY)" ]; then \
		echo "Usage: make ks-get KEY=<key>"; \
		echo "Examples: make ks-get KEY=api-key"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/ks-get $(KEY)

.PHONY: ks-list
ks-list:
	@$(REPO_SCRIPTS_DIR)/ks-list

.PHONY: ks-sync-status
ks-sync-status:
	@$(REPO_SCRIPTS_DIR)/ks-sync-status

.PHONY: ks-sync-enable
ks-sync-enable:
	@if [ -z "$(CONTEXT)" ]; then \
		echo "Usage: make ks-sync-enable CONTEXT=<name>"; \
		echo "Examples: make ks-sync-enable CONTEXT=j1"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/ks-sync-enable $(CONTEXT)

.PHONY: ks-sync-link
ks-sync-link:
	@if [ -z "$(CONTEXT)" ]; then \
		echo "Usage: make ks-sync-link CONTEXT=<name>"; \
		echo "Examples: make ks-sync-link CONTEXT=j1"; \
		exit 1; \
	fi
	@$(REPO_SCRIPTS_DIR)/ks-sync-link $(CONTEXT)

.PHONY: ks-help
ks-help:
	@echo "KS Context Management Commands:"
	@echo "  make ks-init CONTEXT=<name>           - Initialize new keychain context"
	@echo "  make ks-set CONTEXT=<name>            - Set active context"
	@echo "  make ks-context                       - Show current context"
	@echo "  make ks-add KEY=<key> [VALUE=<val>]   - Add secret to current context"
	@echo "  make ks-get KEY=<key>                 - Get secret from current context"
	@echo "  make ks-list                          - List all secrets in current context"
	@echo ""
	@echo "iCloud Sync Commands:"
	@echo "  make ks-sync-status                   - Show sync status of all keychains"
	@echo "  make ks-sync-enable CONTEXT=<name>    - Enable iCloud sync (first device)"
	@echo "  make ks-sync-link CONTEXT=<name>      - Link to iCloud keychain (other devices)"
	@echo ""
	@echo "Examples:"
	@echo "  make ks-init CONTEXT=j1"
	@echo "  make ks-set CONTEXT=j1"
	@echo "  make ks-add KEY=JIRA_TOKEN VALUE='mytoken'"
	@echo "  make ks-sync-enable CONTEXT=j1"
	@echo "  make ks-sync-status"
	@echo ""
	@echo "Documentation:"
	@echo "  README_KS.md       - Complete documentation"
	@echo "  README_KS_SYNC.md  - iCloud sync guide"
	@echo "  KS_QUICKSTART.md   - Quick start guide"

.PHONY: help
help:
	@echo "Available Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  make link          - Create symlinks for scripts"
	@echo "  make clean         - Remove symlinks and restore backup"
	@echo ""
	@echo "Jira Automation:"
	@echo "  make jira-help     - Show Jira commands"
	@echo ""
	@echo "KS Context Management:"
	@echo "  make ks-help       - Show KS commands"
