setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
bindkey "^?" backward-delete-char

zstyle ':compinstall' filename '/home/dominik/.zshrc'
zstyle ':completion:*' menu select
zstyle ':vcs_info:git:*' formats '%s %b'
zmodload zsh/complist

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

autoload -Uz compinit
compinit
autoload -Uz run-help
autoload -Uz vcs_info

precmd() { vcs_info }
setopt prompt_subst

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

if [[ -r ~/.envrc ]]; then
    . ~/.envrc
fi

. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end

PS1='%B%F{green}%n@%m%f:%F{blue}%~%f$%b '
#PS1='%B%F{yellow}%n@%m%f:%F{blue}%~%f$%b '
#PS1='%B%F{red}%n@%m%f:%F{blue}%~%f$%b '
RPS1='%B%(?..%F{red}%?%f)%  %F{yellow}${vcs_info_msg_0_}%f%b'
