#!/usr/bin/env bash
#
# install.sh — symlink the dotfiles in this repo into $HOME.
#
# For each tracked dotfile (including nested ones like .config/ghostty/config),
# creates a symlink at the matching path under $HOME. Anything already present
# at the destination (a real file, dir, or a symlink pointing elsewhere) is
# left untouched and skipped; only correct existing symlinks are treated as
# already done. This script never clobbers existing files.
#
# Usage:
#   ./install.sh          # create the symlinks
#   ./install.sh --dry-run # show what would happen, change nothing

set -euo pipefail

# Directory this script lives in — the source of truth for the dotfiles.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && DRY_RUN=1

# Files/dirs to never link, relative to DOTFILES_DIR.
EXCLUDES=(".git" "install.sh" "bootstrap_mac.sh" "README.md")

is_excluded() {
    local path="$1"
    for ex in "${EXCLUDES[@]}"; do
        [[ "$path" == "$ex" || "$path" == "$ex/"* ]] && return 0
    done
    return 1
}

link_one() {
    local rel="$1"
    local src="$DOTFILES_DIR/$rel"
    local dst="$HOME/$rel"

    # Already the correct symlink? Nothing to do.
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "ok   $rel (already linked)"
        return
    fi

    # Anything already in the way (real file, dir, or a symlink pointing
    # elsewhere) is left untouched — we never clobber existing files.
    if [[ -e "$dst" || -L "$dst" ]]; then
        echo "skip $rel (exists, not clobbering) -> $dst"
        return
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "would link $rel -> $src"
        return
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "link $rel -> $src"
}

# Discover every regular file under DOTFILES_DIR, skipping excludes.
while IFS= read -r -d '' file; do
    rel="${file#"$DOTFILES_DIR"/}"
    is_excluded "$rel" && continue
    link_one "$rel"
done < <(find "$DOTFILES_DIR" -type f -print0)

echo "Done."
