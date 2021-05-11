shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -u autocd
set -o vi

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

if [[ -r ~/.envrc ]]; then
    . ~/.envrc
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
fi

RESET="\[\017\]"
RED="\[\033[31;1m\]"
GREEN="\[\033[32;1m\]"
YELLOW="\[\033[33;1m\]"
BLUE="\[\033[34;1m\]"
WHITE="\[\033[00m\]"
BOLDWHITE="\[\033[37;1m\]"

if [[ $SSH_TTY ]]; then
    PROMPT_COLOR=$YELLOW
elif [[ $UID == 0 ]]; then
    PROMPT_COLOR=$RED
else
    PROMPT_COLOR=$GREEN
fi

function prompt_retrun_value() {
    RET=$?; [ "$RET" != 0 ] && echo "$RET "
}

export PS1="${PROMPT_COLOR}\u${BOLDWHITE}@${PROMPT_COLOR}\h ${BLUE}\w ${RED}\$(prompt_retrun_value)${WHITE}>>> ${RESET}"
