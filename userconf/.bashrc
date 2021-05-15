shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -u autocd
set -o vi

[ -r ~/.envrc ] && . ~/.envrc
[ -r ~/.aliasrc ] && . ~/.aliasrc
[ -r ~/.customrc ] && . ~/.customrc
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

. "$HOME/.shell_plugins/pyenv/plugin.sh"
. "$HOME/.shell_plugins/n/plugin.sh"

RESET="\[\017\]"
RED="\[\033[31;1m\]"
GREEN="\[\033[32;1m\]"
YELLOW="\[\033[33;1m\]"
BLUE="\[\033[34;1m\]"
WHITE="\[\033[00m\]"
BOLDWHITE="\[\033[37;1m\]"

PROMPT_COLOR=$GREEN
[ "$UID" == "0" ] && PROMPT_COLOR=$RED
[ "$SSH_TTY" ] && PROMPT_COLOR=$YELLOW

prompt_retrun_value() { RET=$?; [ "$RET" != "0" ] && echo "$RET "; }

export PS1="${PROMPT_COLOR}\u${BOLDWHITE}@${PROMPT_COLOR}\h ${BLUE}\w ${RED}\$(prompt_retrun_value)${WHITE}>>> ${RESET}"
