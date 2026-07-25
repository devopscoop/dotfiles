# AGENTS.md

Instructions for AI coding agents working in this repo.

`CLAUDE.md` is a symlink to this file, so this is the single source of truth for
every agent. Edit `AGENTS.md`; never replace `CLAUDE.md` with a regular file —
that reverts a deliberate commit and trips the `destroyed-symlinks` pre-commit
hook.

## What this repo is

A shared dotfiles repo. Each top-level directory is one person's namespace
(currently only `3uzbcqje/`). There is no shared or common layer, and nothing
config-related belongs at the root.

Paths inside a user directory mirror `$HOME` exactly:
`3uzbcqje/.config/ghostty/config` installs to `~/.config/ghostty/config`. To add
a dotfile, put it at the same relative path it occupies under `$HOME` — there is
no per-file registration anywhere.

## Commands

There is no build and no test suite. `pre-commit` is the only checker.

```shell
# Symlink a user's dotfiles into $HOME
./3uzbcqje/install.sh --dry-run   # preview; changes nothing
./3uzbcqje/install.sh

# macOS first-time setup: brew bundle, then make Homebrew bash the login shell
./3uzbcqje/bootstrap_mac.sh

# Packages (macOS)
brew bundle --file=3uzbcqje/Brewfile
brew bundle dump --force --file=3uzbcqje/Brewfile   # recapture from this machine

# Lint — the config is per-user, so --config is always required
pre-commit install --config 3uzbcqje/.pre-commit-config.yaml
pre-commit run --all-files --config 3uzbcqje/.pre-commit-config.yaml
pre-commit run gitleaks --all-files --config 3uzbcqje/.pre-commit-config.yaml
```

## install.sh contract

- It links every regular file under the user directory except `EXCLUDES`
  (`.git`, `install.sh`, `bootstrap_mac.sh`, `README.md`). Everything else lands
  in `$HOME`, including `Brewfile`, `.pre-commit-config.yaml`, and
  `.gitleaks.toml`. A new helper script added to a user directory must go in
  `EXCLUDES` or it gets symlinked into `$HOME` too.
- It never clobbers. An existing file, directory, or foreign symlink at the
  destination is skipped, not replaced, so re-running is safe.

## Editing .bashrc

The ordering in `3uzbcqje/.bashrc` is load-bearing and was arrived at by
debugging silent failures. Preserve it:

1. `unset PROMPT_COMMAND` must stay `unset`, not `PROMPT_COMMAND=()` — an empty
   array still triggers the bash-preexec 0.6.0 bug that kills atuin history
   capture.
1. `bash-completion` is sourced before any per-tool completion (`kubectl`,
   `flux`, `gh`).
1. `bash-preexec` is sourced before `atuin init` and `starship init`. Both
   register into `precmd_functions`/`preexec_functions`, and bash-preexec is
   what runs those arrays; the wrong order fails silently.

The file is sourced on both macOS and Linux. macOS-only lines sit behind
`[[ "$(uname)" == "Darwin" ]]` (GNU coreutils PATH prepends, `GPG_TTY`,
pinentry-mac) and Linux-only lines behind the inverse (`SUDO_ASKPASS`,
`codium`). New additions need the same guarding.

## Package manifests

Package manifests are per-user in this repo — there is deliberately NO root-level Brewfile or pkglist.txt, because everyone's toolset differs. Each user keeps a Brewfile in their own directory (e.g. `3uzbcqje/Brewfile`).

- When dotfiles in a user's directory start referencing a new tool, add it to THAT user's Brewfile (or regenerate it with `brew bundle dump --force --file=<dir>/Brewfile`), and remove entries for tools no longer referenced.
- Do not create root-level package manifests.
- Update the "Install required packages" section in README.md if the install workflow changes.

The Brewfile is macOS-only; Linux package state is not tracked in this repo.

## Git and CI

- Commits are GPG-signed with `log.showSignature = true`, so `git log` output is
  interleaved with gpg verification lines. Use `git log --no-show-signature`
  when parsing it.
- The workflows in `.github/workflows/` pin the action SHA alongside `--model`
  and `--effort`. Keep the SHA pins — `actionlint` and `zizmor` check these
  files in pre-commit. Their inline comments explain why the permission scopes
  and tool allowlists are shaped the way they are; read them before widening
  either.
- `mdformat` (gfm, toc, black) reformats markdown on commit, `README.md`
  excepted. Expect it to normalize whatever you write here.
- These dotfiles are published. Scrub secrets and personal info before
  committing; gitleaks runs in pre-commit. Note that `3uzbcqje/.gitleaks.toml`
  is a per-user dotfile that `install.sh` links into `$HOME` — the hook is not
  pointed at it and there is no root-level `.gitleaks.toml`, so the repo scan
  uses gitleaks' default rules.
