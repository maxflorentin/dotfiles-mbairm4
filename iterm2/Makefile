# Define the location of the iTerm2 preferences file on your system
ITERM_PREFS_FILE := $(HOME)/Library/Preferences/com.googlecode.iterm2.plist

# Define where the preferences file will be stored inside your repo
REPO_ITERM_DIR := $(CURDIR)/config

.PHONY: backup
backup:
	@echo "Backing up iTerm2 configuration..."
	# Create the destination directory if it doesn't exist
	@mkdir -p $(REPO_ITERM_DIR)
	# Copy the preferences file to the repository
	@cp $(ITERM_PREFS_FILE) $(REPO_ITERM_DIR)/
	@echo "iTerm2 configuration backup complete."

.PHONY: link
link:
	@echo "Creating symlink for iTerm2 preferences..."
	# Check if the preferences file already exists
	@if [ -f "$(ITERM_PREFS_FILE)" ]; then \
		echo "Moving existing iTerm2 preferences to a backup file..."; \
		mv $(ITERM_PREFS_FILE) $(ITERM_PREFS_FILE).bak; \
	fi
	# Create the symbolic link:
	# -s: create a symbolic link
	# -f: force (remove existing destination files)
	# -n: treat destination as a normal file if it's a directory
	@ln -sfn $(REPO_ITERM_DIR)/$(notdir $(ITERM_PREFS_FILE)) $(ITERM_PREFS_FILE)
	@echo "iTerm2 symlink created successfully."

.PHONY: clean
clean:
	@echo "Removing iTerm2 symlink..."
	# Remove the symbolic link itself
	@rm -f $(ITERM_PREFS_FILE)
	@echo "Restoring backup if it exists..."
	# Check if a backup file exists and restore it
	@if [ -f "$(ITERM_PREFS_FILE).bak" ]; then \
		mv $(ITERM_PREFS_FILE).bak $(ITERM_PREFS_FILE); \
		echo "iTerm2 preferences restored from backup." \
	else \
		echo "No iTerm2 backup found to restore." \
	fi
