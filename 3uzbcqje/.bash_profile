#
# ~/.bash_profile
#
# macOS terminals (Terminal.app, iTerm2, etc.) start bash as a *login* shell.
# Login shells read ~/.bash_profile / ~/.bash_login / ~/.profile and never
# ~/.bashrc. Source .bashrc here so interactive setup runs in both the
# login-shell (macOS) and non-login-shell (typical Linux) cases.
[[ -f ~/.bashrc ]] && . ~/.bashrc
