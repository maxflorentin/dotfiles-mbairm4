#!/bin/sh

echo "Generating a new SSH key for GitHub..."

KEY_PATH="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH" ]; then
    echo "SSH key already exists at $KEY_PATH. Do you want to overwrite it? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Overwriting existing SSH key..."
        rm -f "$KEY_PATH" "$KEY_PATH.pub"
    else
        echo "Aborting SSH key generation."
        exit 0
    fi
fi

# Generating a new SSH key
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
ssh-keygen -t ed25519 -C $1 -f ~/.ssh/id_ed25519

# Adding your SSH key to the ssh-agent
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
eval "$(ssh-agent -s)"

touch ~/.ssh/config
chmod 600 ~/.ssh/config

# Add/update SSH config entries without overwriting the whole file
# Using sed to ensure idempotency for specific lines (macOS sed)
update_ssh_config() {
    local key="$1"
    local value="$2"
    if grep -q "^$key" ~/.ssh/config; then
        sed -i '' "s|^$key.*|$key $value|" ~/.ssh/config
    else
        echo "$key $value" >> ~/.ssh/config
    fi
}

# Ensure Host * is present at the top or added
if ! grep -q "^Host \*" ~/.ssh/config; then
    echo -e "Host *\n$(cat ~/.ssh/config)" > ~/.ssh/config
fi

update_ssh_config "AddKeysToAgent" "yes"
update_ssh_config "UseKeychain" "yes"
update_ssh_config "IdentityFile" "~/.ssh/id_ed25519"

ssh-add -K ~/.ssh/id_ed25519

# Adding your SSH key to your GitHub account
# https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
echo "run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub"
