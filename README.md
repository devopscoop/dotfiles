# dotfiles

## Overview

Share your dotfiles! Browse other people's dotfiles. Get smarter.

## Install required packages

Package manifests live in each user's directory rather than the repo root, since everyone's toolset differs. For example, [3uzbcqje/Brewfile](3uzbcqje/Brewfile) installs that user's packages on macOS:

```shell
brew bundle --file=3uzbcqje/Brewfile
```

or run [3uzbcqje/bootstrap_mac.sh](3uzbcqje/bootstrap_mac.sh), which runs `brew bundle` and sets Homebrew bash as the default shell. To capture your own machine's packages into your directory:

```shell
brew bundle dump --file=<your-dir>/Brewfile
```

## Usage

1. Create a directory for yourself.
1. Put all of your dotfiles in the directory.
1. Check your files for secrets or personal info before you commit them.
1. Optionally, replace the dotfiles in your home directory with symlinks to the files in this repo, so you can sync your files to the repo easily.
   ```
   cd ~; for f in ~/codeberg.org/devopscoop/dotfiles/3uzbcqje/.*; do ln -s "$f"; done
   ```
