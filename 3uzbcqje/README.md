# 3uzbcqje

Paths in this directory mirror `$HOME`. `./install.sh` symlinks them into place
and never overwrites existing files (`./install.sh --dry-run` to preview).

## git-sync

`~/.local/bin/git-sync-all` keeps every git repo under `~/git` up to date, at
any depth. It skips anything under `.terraform/` or `node_modules/`, along with
submodules and linked worktrees. For each repo it:

- adds any missing `codeberg`, `github` or `gitlab` remote to
  `~/git/<owner>-<name>`, pointing at `git@<forge>:<owner>/<name>.git`. An
  `origin` on one of those forges is renamed instead. A missing `rad` remote
  can't be added, since its URL holds a repo ID; run `rad init` for that.
- checks its remotes, and skips the repo if they're wrong: `3uzbcqje-*`,
  `6j0-org-*` and `devopscoop-*` must have exactly `codeberg`, `github`,
  `gitlab` and `rad`, each pointing at that host; `Equal-Vote/*` and `EdgeApp/*`
  must have only `origin` on GitHub; `aur.archlinux.org/*` must have only
  `origin` at `ssh://aur@aur.archlinux.org/`. The `<node-id>` and
  `<alias>@<node-id>` remotes rad adds for peers are ignored, in this check and
  in the sync.
- fetches all remotes, pruning deleted branches
- fast-forwards the default branch to each remote's copy of it, without
  switching branches; a remote that has diverged is reported, not touched
- pushes the default branch to every remote that is behind (never forced)

Then it lists every unarchived repo that `3uzbcqje`, `devopscoop` and `6j0-org`
own on GitHub, GitLab and Codeberg, and reports each one that isn't cloned. A
repo counts as cloned if it's at `~/git/<owner>-<name>` or
`~/git/<owner>/<name>`, or if any clone has a remote pointing at it. GitHub is
read through `gh`, so its private repos are included; GitLab and Codeberg are
read without a token, so only their public repos are.

It only manages the default branch; other branches are ignored. It never creates
merge commits or touches uncommitted work. Repos that need you (wrong remotes,
uncommitted changes, a diverged default branch, a failed fetch or push, or a
repo on a forge that isn't cloned) are listed in its output and raise a desktop
notification.

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

1. Link the files:

   ```shell
   ./install.sh
   ```

1. Make sure an ssh-agent is listening at `$XDG_RUNTIME_DIR/ssh-agent.socket`
   with your key loaded. The service sets `SSH_AUTH_SOCK` to that path itself,
   so it doesn't depend on what your shell or desktop exported. Without an
   agent there, every repo reports `fetch failed`. See
   [Start ssh-agent with systemd user](https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user).
   `AddKeysToAgent yes` in `~/.ssh/config` loads the key the first time you
   use ssh after logging in.

   If you use GNOME Keyring's agent instead (`echo $SSH_AUTH_SOCK` shows
   `.../gcr/ssh`), point the service at it with a drop-in. Run this after
   linking the files, because `systemctl edit` fails on a unit that doesn't
   exist yet:

   ```shell
   printf '[Service]\nEnvironment=SSH_AUTH_SOCK=%%t/gcr/ssh\n' |
     systemctl --user edit --stdin git-sync.service
   ```

   `--stdin` needs systemd 256 or newer. On older versions, run
   `systemctl --user edit git-sync.service` and paste these lines in:

   ```ini
   [Service]
   Environment=SSH_AUTH_SOCK=%t/gcr/ssh
   ```

1. Enable the timer:

   ```shell
   systemctl --user daemon-reload
   systemctl --user enable --now git-sync.timer
   ```

1. Run it once now and check the output and the next scheduled run:

   ```shell
   systemctl --user start git-sync.service
   journalctl --user -u git-sync -e
   systemctl --user list-timers git-sync.timer
   ```

To turn it off: `systemctl --user disable --now git-sync.timer`
