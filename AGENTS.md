# AGENTS.md

Instructions for AI coding agents working in this repo.

## Package manifests

Package manifests are per-user in this repo — there is deliberately NO root-level Brewfile or pkglist.txt, because everyone's toolset differs. Each user keeps a Brewfile in their own directory (e.g. `3uzbcqje/Brewfile`).

- When dotfiles in a user's directory start referencing a new tool, add it to THAT user's Brewfile (or regenerate it with `brew bundle dump --force --file=<dir>/Brewfile`), and remove entries for tools no longer referenced.
- Do not create root-level package manifests.
- Update the "Install required packages" section in README.md if the install workflow changes.
