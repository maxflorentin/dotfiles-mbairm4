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
