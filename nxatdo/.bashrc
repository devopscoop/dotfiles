#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias nocomment=$'sed -E \'/^[ \t]*#/d;/^[ \t]*$/d;\''
alias grepp='grep -rIi --exclude-dir .git --exclude-dir node_modules --exclude-dir .terraform'
alias codium='/opt/vscodium-bin/codium --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
alias difff='diff -w -W 240 -y --color=always --suppress-common-lines'
alias awslogin="okta-aws-cli web -s 42300 --cache-access-token --all-profiles"
alias gen-rand-username=$'openssl rand -base64 13 | sed \'s/[^a-z]//g\''
alias local-ai='sudo docker run --rm -ti --name local-ai -p 8080:8080 \
  -v "${HOME}/models":/models \
  localai/localai:latest-aio-gpu-intel'

export EDITOR=vim
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin"

# https://wiki.archlinux.org/title/Git
source /usr/share/git/completion/git-prompt.sh
export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWCONFLICTSTATE=yes
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto

source '/opt/kube-ps1/kube-ps1.sh'

# Adding git and kube stuff to prompt
PS1='[\w $(__git_ps1 "(%s)") $(kube_ps1)]\$ '

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

# Using bash-preexec and atuin for magical shell history
[[ -f /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh
eval "$(atuin init bash --disable-up-arrow)"

# source "${HOME}/gitlab.com/dedevsecops/bin/git_lib.sh"

# https://cli.github.com/manual/gh_completion
eval "$(gh completion -s bash)"

# Do this once to use Gnome Keyring seahorse with ssh
# systemctl --user enable gcr-ssh-agent.socket

# https://docs.k0sproject.io/stable/shell-completion/
source <(k0s completion bash)

# Use this when you log into this user via the console
# eval "$(ssh-agent -s)"
[[ -f /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh
eval "$(atuin init bash --disable-up-arrow)"
