HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
bindkey "^?" backward-delete-char


zstyle ':compinstall' filename '/home/dominik/.zshrc'
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit

autoload -Uz run-help


PS1="%B%F{green}%n@%m%f:%F{blue}%~%f$%b "
RPS1="%(?..%?)%"

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
