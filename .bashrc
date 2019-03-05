HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

set -o vi

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export VISUAL=nvim
export EDITOR=nvim
export PAGER=less
export PATH="$HOME/bin:$PATH"
