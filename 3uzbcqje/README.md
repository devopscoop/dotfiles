# 3uzbcqje

Paths in this directory mirror `$HOME`. `./install.sh` symlinks them into place
and never overwrites existing files (`./install.sh --dry-run` to preview).

## git-sync

`~/.local/bin/git-sync-all` keeps every git repo under `~/git` up to date, at
any depth. It skips anything under `.terraform/` or `node_modules/`, along with
submodules and linked worktrees. For each repo it:

- fetches all remotes, pruning deleted branches
- fast-forwards the default branch without switching branches; a diverged
  default branch is reported, not touched
- deletes local branches already merged into the default branch, except ones
  checked out in a worktree

It never creates merge commits or touches uncommitted work. Repos that need you
(uncommitted changes, leftover branches, a diverged default branch, a failed
fetch) are listed in its output and raise a desktop notification.

Run it by hand any time with `git-sync-all`. To run it daily, enable it for your
OS below.

### macOS (launchd)

Runs daily at 08:00, or when the Mac wakes if it was asleep then, and at every
login. Output goes to `~/Library/Logs/git-sync.log`.

1. Link the files:

   ```shell
   ./install.sh
   ```

1. Load the agent:

   ```shell
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.git-sync.plist
   ```

1. Run it once now and check the output:

   ```shell
   launchctl kickstart gui/$(id -u)/local.git-sync
   tail ~/Library/Logs/git-sync.log
   ```

To turn it off: `launchctl bootout gui/$(id -u)/local.git-sync`

### Linux (systemd user timer)

Runs daily at 08:00, or when the machine resumes if it was suspended then. If it
was off or you were logged out, it runs at your next login. It only runs while
you're logged in. Output goes to the journal.

1. Make sure an ssh-agent is listening at `$XDG_RUNTIME_DIR/ssh-agent.socket`
   with your key loaded. User services don't see your shell's `SSH_AUTH_SOCK`,
   so the service points there directly. Without it, every repo reports
   `fetch failed`. See
   [Start ssh-agent with systemd user](https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user).
   `AddKeysToAgent yes` in `~/.ssh/config` loads the key the first time you
   use ssh after logging in.

   If you use GNOME Keyring's agent (`gcr-ssh-agent.socket`) instead, point the
   service at it:

   ```shell
   systemctl --user edit git-sync.service
   ```

   ```ini
   [Service]
   Environment=SSH_AUTH_SOCK=%t/gcr/ssh
   ```

1. Link the files:

   ```shell
   ./install.sh
   ```

1. Enable the timer:

   ```shell
   systemctl --user daemon-reload
   systemctl --user enable --now git-sync.timer
   ```

1. Run it once now and check the output and the next scheduled run:

   ```shell
   systemctl --user start git-sync.service
   journalctl --user -u git-sync
   systemctl --user list-timers git-sync.timer
   ```

To turn it off: `systemctl --user disable --now git-sync.timer`
