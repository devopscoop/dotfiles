#!/usr/bin/env bash
#
# install.sh — symlink the dotfiles in this repo into $HOME.
#
# For each tracked dotfile (including nested ones like .config/ghostty/config),
# creates a symlink at the matching path under $HOME. Anything already present
# at the destination (a real file, dir, or a symlink pointing elsewhere) is
# left untouched and skipped; only correct existing symlinks are treated as
# already done. By default this script never clobbers existing files.
#
# With --force, whatever is in the way is replaced by the link. Symlinks
# pointing elsewhere are simply replaced; real files and directories are moved
# aside to <name>.bak.<timestamp> first, so nothing is lost.
#
# Usage:
#   ./install.sh           # create the symlinks
#   ./install.sh --dry-run # show what would happen, change nothing
#   ./install.sh --force   # replace anything in the way (backing up real files)
#   ./install.sh --force --dry-run # show what --force would do

set -euo pipefail

# Directory this script lives in — the source of truth for the dotfiles.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
FORCE=0
for arg in "$@"; do
    case "$arg" in
        -n | --dry-run) DRY_RUN=1 ;;
        -f | --force) FORCE=1 ;;
        -h | --help)
            sed -n '2,/^$/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
            exit 0
            ;;
        *)
            echo "unknown option: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

# Suffix for backups of real files moved aside by --force.
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

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
    # elsewhere) is left untouched unless --force was given.
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ $FORCE -eq 0 ]]; then
            echo "skip $rel (exists, not clobbering) -> $dst"
            return
        fi
        if [[ -L "$dst" ]]; then
            # A foreign symlink holds no data; just replace it.
            local old
            old="$(readlink "$dst")"
            if [[ $DRY_RUN -eq 1 ]]; then
                echo "would replace symlink $rel (was -> $old) -> $src"
                return
            fi
            rm "$dst"
            echo "unlink $rel (was -> $old)"
        else
            # A real file or directory: move it aside rather than delete it.
            if [[ $DRY_RUN -eq 1 ]]; then
                echo "would back up $dst -> $dst$BACKUP_SUFFIX and link $rel -> $src"
                return
            fi
            mv "$dst" "$dst$BACKUP_SUFFIX"
            echo "backup $dst -> $dst$BACKUP_SUFFIX"
        fi
    elif [[ $DRY_RUN -eq 1 ]]; then
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
