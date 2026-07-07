#!/usr/bin/env bash

brew install bash

# pinentry-mac: native macOS passphrase dialog + Keychain for GPG signing.
# Configured in .bashrc's Darwin section.
brew install pinentry-mac

# Add brew's bash to allowed shells
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells

# Set it as default
chsh -s $(brew --prefix)/bin/bash

echo $BASH_VERSION  # should be 5.x, not the Apple 3.2 fossil

# Create an SSH key
# ssh-keygen

# Add it to apple keychain so you don't have to enter the passphrase constantly
# ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Clone all git repos
# gh repo list devopscoop --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | \
#   xargs -P4 -I{} gh repo clone {}
