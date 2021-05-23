# clone pluginmanager if not exist
[ -d ~/.zinit/bin ] || git clone https://github.com/zdharma/zinit.git ~/.zinit/bin

[ -r ~/.envrc ] && . ~/.envrc
[ -r ~/.customrc ] && . ~/.customrc
[ -r ~/.aliasrc ] && . ~/.aliasrc

COMPLETION_WAITING_DOTS="true"
# plugins
source "$HOME/.zinit/bin/zinit.zsh"
zinit light "dominik-schwabe/vi-mode.zsh"
zinit snippet OMZL::completion.zsh
zinit ice wait'!0' lucid
zinit light "$HOME/.shell_plugins/asdf"
zinit ice wait'0' lucid
zinit snippet OMZP::git
zinit ice wait'0' lucid
zinit light "agkozak/zsh-z"
zinit ice wait'0' lucid
zinit light "t413/zsh-background-notify"
zinit ice wait'0' lucid
zinit light "zsh-users/zsh-history-substring-search"
zinit ice wait'0' lucid
zinit light "zsh-vi-more/vi-increment"
zinit ice wait'0' lucid
zinit light "zdharma/fast-syntax-highlighting"
zinit ice wait'0' lucid
zinit light "MichaelAquilina/zsh-you-should-use"
zinit ice wait'0' lucid
zinit light "kutsan/zsh-system-clipboard"
zinit ice wait'0' lucid atload'zicompinit'
zinit light "zsh-users/zsh-completions"
#zinit light "lukechilds/zsh-better-npm-completion"
#zinit light "zdharma/history-search-multi-word"
#zinit light "zsh-users/zsh-autosuggestions"

[[ -z "$LS_COLORS" ]] && (( $+commands[dircolors] )) && eval "$(dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

## use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

chpwd() {
    emulate -L zsh
    ls
}

unset correctall

# theme
DEFAULT_COLOR="2"
ROOT_COLOR="161"
SSH_COLOR="214"

PROMPT_COLOR=${DEFAULT_COLOR:-green}
[ "$UID" = "0" ] && PROMPT_COLOR=${ROOT_COLOR:-red}
[ "$SSH_TTY" ] && PROMPT_COLOR=${SSH_COLOR:-blue}

git_prompt_info() { ref=$(git symbolic-ref HEAD 2> /dev/null) && echo " ${ref#refs/heads/}" }
PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{7}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f%B%F{3}$(git_prompt_info)%f%b%b >>> '

_get_asdf_versions_prompt() {
    VARIABLE_NAME="ASDF_$(tr '[a-z]' '[A-Z]' <<< $1)_VERSION"
    if DEFINED_NAME=$(export -p "$VARIABLE_NAME") 2>/dev/null && [[ "$DEFINED_NAME" = 'export'* ]]; then
        eval "local VERSIONS=\$$VARIABLE_NAME"
        [ -n "$VERSIONS" ] && {
            echo "$VERSIONS"
            return 0
        }
    fi
    [ -r $HOME/.tool-versions ] || return 1
    VERSIONS=$(sed -n -e "/^$1\s/{s/^$1\s//p;q}" < $HOME/.tool-versions)
    [ -z "$VERSIONS" ] && return 1
    echo $VERSIONS
}

get_python_version() { _get_asdf_versions_prompt python || echo system }
get_node_version() { _get_asdf_versions_prompt nodejs || echo system }
RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b%F{9}%B $(get_python_version)%b%f%F{34}%B $(get_node_version)%b%f'
# theme end

setopt hist_ignore_dups hist_ignore_space interactivecomments noextendedhistory nosharehistory auto_cd multios prompt_subst

exit_zsh() { exit }
zle -N exit_zsh
bindkey -M viins '^D' exit_zsh
bindkey -M vicmd '^D' exit_zsh

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

expand-alias() { zle _expand_alias }
zle -N expand-alias
bindkey -M viins '^[OS' expand-alias
bindkey -M vicmd '^[OS' expand-alias

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

_pacman_update() {
    LBUFFER="sudo pacman -Syu"
    RBUFFER=""
    zle accept-line
}

zle -N _pacman_update
bindkey -M vicmd '^[[15~' _pacman_update
bindkey -M viins '^[[15~' _pacman_update
bindkey -M vicmd '^[[[E' _pacman_update
bindkey -M viins '^[[[E' _pacman_update
