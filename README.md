# dotfiles

## Overview

Share your dotfiles! Browse other people's dotfiles. Get smarter.

## Usage

1. Create a directory for yourself.
1. Put all of your dotfiles in the directory.
1. Check your files for secrets or personal info before you commit them.
1. Optionally, replace the dotfiles in your home directory with symlinks to the files in this repo, so you can sync your files to the repo easily.
   ```
   cd ~; for f in ~/codeberg.org/devopscoop/dotfiles/nxatdo/.*; do ln -s "$f"; done
   ```
