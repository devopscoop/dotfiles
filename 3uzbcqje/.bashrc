#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Fix macOS shitfuckery
if [[ "$(uname)" == "Darwin" ]]; then
  export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/gawk/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/bash/bin:$PATH"  # newer bash

  # Tell gpg-agent which terminal to use for the pinentry passphrase prompt.
  # Without this, git commit signing fails with "Inappropriate ioctl for device".
  # https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
  export GPG_TTY=$(tty)

  # Use the native macOS pinentry dialog (+ Keychain) for GPG passphrases.
  # Installed by bootstrap_mac.sh. Only writes the config once, and only
  # reloads the agent when it actually changed.
  if command -v pinentry-mac >/dev/null 2>&1 &&
     ! grep -qs pinentry-mac ~/.gnupg/gpg-agent.conf; then
    mkdir -p ~/.gnupg
    echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent
  fi
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias nocomment=$'sed -E \'/^[ \t]*#/d;/^[ \t]*$/d;\''
alias grepp='grep -rIi --exclude-dir .git --exclude-dir node_modules --exclude-dir .terraform'
if [ "$(uname)" != "Darwin" ]; then
  alias codium='/opt/vscodium-bin/codium --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
fi
alias difff='diff -w -W 240 -y --color=always --suppress-common-lines'
alias awslogin="okta-aws-cli web --all-profiles --open-browser --aws-session-duration 42300 --oidc-client-id 0oa1o4hf5l3zhPrXL358 --org-domain dfinity.okta.com --write-aws-credentials"
alias gen-rand-username=$'openssl rand -base64 13 | sed \'s/[^a-z]//g\''
alias local-ai='sudo docker run --rm -ti --name local-ai -p 8080:8080 \
  -v "${HOME}/models":/models \
  -v "${HOME}/backends":/backends \
  localai/localai:latest-aio-gpu-intel'

# Useful for generating profile pictures
# https://jdenticon.com/get-started/cli.html
jdenticon() {
  npx jdenticon "${1}" --size 256 --output "${1}.png"
}

export EDITOR=vim
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:${HOME}/go/bin"

# Commenting out while trying starship
# Adding git and kube stuff to prompt
# https://wiki.archlinux.org/title/Git
# source /usr/share/git/completion/git-prompt.sh
# export GIT_PS1_SHOWCOLORHINTS=true
# export GIT_PS1_SHOWCONFLICTSTATE=yes
# export GIT_PS1_SHOWDIRTYSTATE=true
# export GIT_PS1_SHOWSTASHSTATE=true
# export GIT_PS1_SHOWUNTRACKEDFILES=true
# export GIT_PS1_SHOWUPSTREAM=auto
# source '/opt/kube-ps1/kube-ps1.sh'
# PS1='[\w $(__git_ps1 "(%s)") $(kube_ps1)]\$ '

# Programmable completion (bash-completion@2). Must be sourced before the
# per-tool completions below so the completion machinery (_init_completion,
# etc.) and the drop-ins in bash-completion.d (git, brew, ssh, make, ...) load.
# https://github.com/scop/bash-completion#installation
if [[ "$(uname)" == "Darwin" ]]; then
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
else
  source /usr/share/bash-completion/bash_completion
fi

# kubectl
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
alias kns='kubectl config set-context --current --namespace'

# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# https://github.com/luksa/kubectl-plugins/tree/master
export PATH="${PATH}:$HOME/kubectl-plugins"

alias kubewatchevents='kubectl get events --sort-by=.metadata.creationTimestamp --watch'

# https://fluxcd.io/flux/installation/
source <(flux completion bash)

# /etc/bash.bashrc seeds PROMPT_COMMAND as an array (xterm title printf), and
# bash-preexec 0.6.0 mishandles array PROMPT_COMMANDs: its deferred installer
# gets string-glued onto element [0], direnv's array-prepend later shifts that
# element to [1] where bash-preexec's cleanup never removes it, and the
# orphaned installer then re-runs 'trap - DEBUG' on every prompt — silently
# killing preexec and atuin history capture. Reset to a plain scalar so
# bash-preexec starts from a clean string. Must be unset, not
# PROMPT_COMMAND=(): an empty array still triggers the bug.
unset PROMPT_COMMAND

# Using bash-preexec and atuin for magical shell history.
# bash-preexec must be sourced BEFORE atuin and starship init: both register
# into precmd_functions/preexec_functions, and bash-preexec is what actually
# runs those arrays. Without it, atuin history capture and the starship prompt
# both silently do nothing.
if [[ "$(uname)" == "Darwin" ]]; then
  source "$(brew --prefix)/etc/profile.d/bash-preexec.sh"
else
  source /usr/share/bash-preexec/bash-preexec.sh
fi
eval "$(atuin init bash --disable-up-arrow)"

# https://cli.github.com/manual/gh_completion
eval "$(gh completion -s bash)"

# Do this once to use Gnome Keyring seahorse with ssh
# systemctl --user enable gcr-ssh-agent.socket
# systemctl --user start gcr-ssh-agent.socket

# https://wiki.archlinux.org/title/SSH_keys
# I can't fucking get GNOME Keyring Seahorse Whateverthefuck working For Cosmic Desktop, so I'm trying this shit:
# systemctl --user enable ssh-agent.service
# systemctl --user start ssh-agent.service
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# https://docs.k0sproject.io/stable/shell-completion/
# source <(k0s completion bash)

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/user/.lmstudio/bin"
# End of LM Studio CLI section

# On macOS this Linux path is absent and setting it makes `sudo -A`
# (e.g. Homebrew cask installers) fail, so only set it on Linux.
if [ "$(uname)" != "Darwin" ]; then
  export SUDO_ASKPASS=/usr/lib/seahorse/ssh-askpass
fi

# Adding a function to set the title of a terminal window
function set-title() {
    TITLE="\e]2;$@\a"
    PS1="${PS1}${TITLE}"
}

# https://direnv.net/docs/hook.html
eval "$(direnv hook bash)"

# https://starship.rs/
# Add some presets (one time)
# starship preset nerd-font-symbols -o ~/.config/starship.toml
eval "$(starship init bash)"
