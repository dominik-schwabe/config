[[ -r ~/.envrc ]] && . ~/.envrc
[[ -r ~/.customrc ]] && . ~/.customrc
[[ -r ~/.genrc ]] && . ~/.genrc
[[ -r ~/.aliasrc ]] && . ~/.aliasrc
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

[[ -r "$HOME/.shell_plugins/asdf/plugin.sh" ]] && . "$HOME/.shell_plugins/asdf/plugin.sh"

shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -u autocd

RESET="\[\017\]"
RED="\[\033[31;1m\]"
GREEN="\[\033[32;1m\]"
YELLOW="\[\033[33;1m\]"
BLUE="\[\033[34;1m\]"
WHITE="\[\033[00m\]"
BOLDWHITE="\[\033[37;1m\]"

PROMPT_COLOR=$GREEN
[[ "$UID" == "0" ]] && PROMPT_COLOR=$RED
[[ "$SSH_TTY" ]] && PROMPT_COLOR=$YELLOW

export PS1="${PROMPT_COLOR}\u${BOLDWHITE}@${PROMPT_COLOR}\h ${BLUE}\w ${YELLOW}$(date +'%H:%M') ${RED}\$(_RET=\$?; [ \"\$_RET\" = 0 ] || echo \"\$_RET \")${WHITE}>>> ${RESET}"
