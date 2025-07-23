# Define the Neovim configuration directory on your system
NVIM_CONFIG_DIR := $(HOME)/.config/nvim

# Define where the configurations will be stored within your repo
# This creates a 'config' subdirectory inside '~/dotfiles/nvim/'
REPO_NVIM_DIR := $(CURDIR)/config

.PHONY: backup
backup:
	@echo "Backing up Neovim configuration..."
	# Create the destination directory if it doesn't exist
	@mkdir -p $(REPO_NVIM_DIR)
	# Copy all contents from NVIM_CONFIG_DIR to REPO_NVIM_DIR
	# We use /* to copy the content of the directory, not the directory itself
	@cp -R $(NVIM_CONFIG_DIR)/* $(REPO_NVIM_DIR)/
	@echo "Neovim configuration backup complete."

.PHONY: link
link:
	@echo "Creating symlinks for Neovim..."
	# Check if the Neovim config directory already exists
	@if [ -d "$(NVIM_CONFIG_DIR)" ]; then \
		echo "Moving existing Neovim configuration to $(HOME)/.config/nvim.bak"; \
		mv $(NVIM_CONFIG_DIR) $(HOME)/.config/nvim.bak; \
	fi
	# Ensure the parent directory (~/.config) exists
	@mkdir -p $(dir $(NVIM_CONFIG_DIR))
	# Create the symbolic link:
	# -s: create a symbolic link
	# -f: force (remove existing destination files)
	# -n: treat destination as a normal file if it's a directory (prevents linking to an existing directory itself)
	@ln -sfn $(REPO_NVIM_DIR) $(NVIM_CONFIG_DIR)
	@echo "Neovim symlink created successfully."

.PHONY: clean
clean:
	@echo "Removing Neovim symlink..."
	# Remove the symbolic link itself
	@rm -f $(NVIM_CONFIG_DIR)
	@echo "Restoring backup if it exists..."
	# Check if a backup directory exists and restore it
	@if [ -d "$(HOME)/.config/nvim.bak" ]; then \
		mv $(HOME)/.config/nvim.bak $(NVIM_CONFIG_DIR); \
		echo "Neovim configuration restored from backup." \
	else \
		echo "No Neovim backup found to restore." \
	fi
