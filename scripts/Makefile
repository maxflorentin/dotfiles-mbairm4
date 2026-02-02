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
	# Remove the symbolic link itself
	@rm -f $(SCRIPTS_DIR)
	@echo "Restoring backup if it exists..."
	# Check if a backup directory exists and restore it
	@if [ -d "$(HOME)/Scripts/dotfiles.bak" ]; then \
		mv $(HOME)/Scripts/dotfiles.bak $(SCRIPTS_DIR); \
		echo "Scripts restored from backup."; \
	else \
		echo "No Scripts backup found to restore."; \
	fi
