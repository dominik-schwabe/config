# clone pluginmanager if not exist
[[ -d ~/.zinit/bin ]] || git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin

[[ -r ~/.envrc ]] && . ~/.envrc
[[ -r ~/.customrc ]] && . ~/.customrc
[[ -r ~/.genrc ]] && . ~/.genrc
[[ -r ~/.aliasrc ]] && . ~/.aliasrc

echo -n "\e[6 q"

COMPLETION_WAITING_DOTS="true"
ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT="true"

# plugins
source "$HOME/.zinit/bin/zinit.zsh"
zinit snippet OMZL::completion.zsh
zinit ice wait'0' lucid
zinit light dominik-schwabe/vi-mode.zsh
zinit ice wait'!0' lucid
zinit light $HOME/.shell_plugins/asdf
zinit ice wait'0' lucid
zinit snippet OMZP::git
zinit ice wait'0' lucid
zinit snippet OMZP::pip
zinit ice wait'0' lucid
zinit light agkozak/zsh-z
zinit ice wait'0' lucid
zinit light t413/zsh-background-notify
zinit ice wait'0' lucid
zinit light zsh-users/zsh-history-substring-search
zinit ice wait'0' lucid
zinit light zsh-vi-more/vi-increment
zinit ice wait'0' lucid
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice wait'0' lucid
zinit light MichaelAquilina/zsh-you-should-use
zinit ice wait'0' lucid silent
zinit light kutsan/zsh-system-clipboard
zinit ice wait'0' lucid silent
zinit light lljbash/zsh-renew-tmux-env
zinit ice wait'0' lucid atload'zicompinit'
zinit light zsh-users/zsh-completions

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
[[ "$UID" = "0" ]] && PROMPT_COLOR=${ROOT_COLOR:-red}
[[ "$SSH_TTY" ]] && PROMPT_COLOR=${SSH_COLOR:-blue}

git_prompt_info() {
    if ref=$(git symbolic-ref HEAD 2>&1); then
        branch=${ref#refs/heads/}
        if [[ "$branch" = "master" || "$branch" = "main" ]]; then
            echo " %F{1}$branch%f"
        else
            echo " %F{3}$branch%f"
        fi
    else
        [[ "$ref" = 'fatal: ref HEAD is not a symbolic ref' ]] && echo " %F{14}no branch%f"
    fi
}
PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{7}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f%B$(git_prompt_info)%b%b >>> '

declare -u _GET_ASDF_VERSION_VARIABLE_NAME
_get_asdf_versions_prompt() {
    _GET_ASDF_VERSION_VARIABLE_NAME=ASDF_$1_VERSION
    if DEFINED_NAME=$(export -p "$_GET_ASDF_VERSION_VARIABLE_NAME") 2>/dev/null && [[ "$DEFINED_NAME" = 'export'* ]]; then
        eval "_VERSIONS=\$$_GET_ASDF_VERSION_VARIABLE_NAME"
        [[ -n "$_VERSIONS" ]] && {
            echo "$_VERSIONS"
            return 0
        }
    fi
    [[ -r $HOME/.tool-versions ]] || return 1
    while read LINE; do
        IFS=" " read _ASDF_PROG_NAME _ASDF_PROG_VERSION <<< $LINE;
        if [[ "$_ASDF_PROG_NAME" = $1 ]]; then
            echo "$_ASDF_PROG_VERSION"
            return 0
        fi
    done < "$HOME/.tool-versions"
    return 1
}

get_python_version() { _get_asdf_versions_prompt python || echo system }
get_node_version() { _get_asdf_versions_prompt nodejs || echo system }
RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b%F{9}%B $(get_python_version)%b%f%F{34}%B $(get_node_version)%b%f'
# theme end

setopt hist_ignore_dups hist_ignore_space interactivecomments noextendedhistory nosharehistory auto_cd multios prompt_subst histignorealldups

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

_yay_update() {
    LBUFFER="yay -Syu"
    RBUFFER=""
    zle accept-line
}

zle -N _yay_update
bindkey -M vicmd '^[[15~' _yay_update
bindkey -M viins '^[[15~' _yay_update
bindkey -M vicmd '^[[[E' _yay_update
bindkey -M viins '^[[[E' _yay_update
