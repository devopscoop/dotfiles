#!/usr/bin/env bash
#
# install.sh — symlink the dotfiles in this repo into $HOME.
#
# For each tracked dotfile (including nested ones like .config/ghostty/config),
# creates a symlink at the matching path under $HOME. Existing real files are
# backed up to <file>.bak; existing correct symlinks are left alone.
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

    if [[ $DRY_RUN -eq 1 ]]; then
        if [[ -e "$dst" || -L "$dst" ]]; then
            echo "would back up $dst and link -> $src"
        else
            echo "would link $rel -> $src"
        fi
        return
    fi

    mkdir -p "$(dirname "$dst")"

    # Back up anything real (or a stale symlink) that's in the way.
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="$dst.bak"
        echo "back up $dst -> $backup"
        mv "$dst" "$backup"
    fi

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
