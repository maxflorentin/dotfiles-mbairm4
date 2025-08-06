# VS Code config directory
VSCODE_CONFIG_DIR := "$(HOME)/Library/Application\ Support/Code/User"

# Repo path
REPO_VSCODE_DIR := $(CURDIR)/config

.PHONY: backup
backup:
	@echo "Backing up VS Code configuration..."
	@mkdir -p $(REPO_VSCODE_DIR)/snippets
	@cp -f "$(VSCODE_CONFIG_DIR)/settings.json" $(REPO_VSCODE_DIR)/ 2>/dev/null || echo "No settings.json found, skipping..."
	@if [ -f "$(VSCODE_CONFIG_DIR)/keybindings.json" ]; then \
		cp -f "$(VSCODE_CONFIG_DIR)/keybindings.json" $(REPO_VSCODE_DIR)/; \
	else \
		echo "No keybindings.json found, skipping..."; \
	fi
	@cp -Rf "$(VSCODE_CONFIG_DIR)/snippets"/* $(REPO_VSCODE_DIR)/snippets/ 2>/dev/null || true
	@code --list-extensions > $(REPO_VSCODE_DIR)/extensions.txt 2>/dev/null || echo "VS Code CLI failed to list extensions (code --list-extensions). Skipping..."

	@echo "VS Code configuration backup complete."

.PHONY: link
link:
	@echo "Creating symlinks for VS Code..."
	@if [ -f "$(VSCODE_CONFIG_DIR)/settings.json" ]; then \
		mv "$(VSCODE_CONFIG_DIR)/settings.json" "$(VSCODE_CONFIG_DIR)/settings.json.bak"; \
	fi
	@if [ -f "$(VSCODE_CONFIG_DIR)/keybindings.json" ]; then \
		mv "$(VSCODE_CONFIG_DIR)/keybindings.json" "$(VSCODE_CONFIG_DIR)/keybindings.json.bak"; \
	fi
	@ln -sfn "$(REPO_VSCODE_DIR)/settings.json" "$(VSCODE_CONFIG_DIR)/settings.json"
	@ln -sfn "$(REPO_VSCODE_DIR)/keybindings.json" "$(VSCODE_CONFIG_DIR)/keybindings.json"
	@echo "VS Code symlinks created."

.PHONY: restore-extensions
restore-extensions:
	@echo "Installing extensions from extensions.txt..."
	@cat $(REPO_VSCODE_DIR)/extensions.txt | xargs -n1 code --install-extension
	@echo "Extensions installed."

.PHONY: clean
clean:
	@echo "Cleaning VS Code symlinks..."
	@rm -f $(VSCODE_CONFIG_DIR)/settings.json
	@rm -f $(VSCODE_CONFIG_DIR)/keybindings.json
	@echo "Restoring backups if present..."
	@if [ -f "$(VSCODE_CONFIG_DIR)/settings.json.bak" ]; then \
		mv $(VSCODE_CONFIG_DIR)/settings.json.bak $(VSCODE_CONFIG_DIR)/settings.json; \
	fi
	@if [ -f "$(VSCODE_CONFIG_DIR)/keybindings.json.bak" ]; then \
		mv $(VSCODE_CONFIG_DIR)/keybindings.json.bak $(VSCODE_CONFIG_DIR)/keybindings.json; \
	fi
	@echo "Done."

