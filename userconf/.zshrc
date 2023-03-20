[[ -r ~/.envrc ]] && . ~/.envrc
[[ -r ~/.genrc ]] && . ~/.genrc
[[ -r ~/.aliasrc ]] && . ~/.aliasrc

[[ -r "$HOME/.shell_plugins/asdf/plugin.sh" ]] && . "$HOME/.shell_plugins/asdf/plugin.sh"

export HISTFILE=~/.zsh_history

echo -n "\e[6 q"

local fzf_common="--hidden --no-ignore --color=always -E '.cache' -E '.asdf' -E '.local' -E '.thunderbird' -E '.rustup' -E '.cargo' -E '.npm' -E node_modules -E '.git' -E '__pycache__'"
FZF_CTRL_T_COMMAND="fd $fzf_common --type file"
FZF_ALT_C_COMMAND="fd $fzf_common --type directory"
FZF_DEFAULT_OPTS="--ansi"

[[ -z $DISPLAY ]] && export ZSH_SYSTEM_CLIPBOARD_DISABLE_DEFAULT_MAPS=1

# plugins
if [[ -z "$MINIMAL_CONFIG" ]]; then
    [[ -d ~/.zi/bin ]] || git clone https://github.com/z-shell/zi ~/.zi/bin
    source ~/.zi/bin/zi.zsh
    zi ice atinit'COMPLETION_WAITING_DOTS=true' atload'unsetopt complete_in_word'
    zi snippet OMZL::completion.zsh
    zi ice wait'0' lucid
    zi light dominik-schwabe/vi-mode.zsh
    zi ice wait'0' lucid
    zi light greymd/docker-zsh-completion
    zi ice wait'0' lucid
    zi snippet OMZP::git
    zi ice wait'0' lucid
    zi snippet OMZP::pip
    zi ice wait'0' lucid
    zi light agkozak/zsh-z
    zi ice wait'0' lucid
    zi light t413/zsh-background-notify
    zi ice wait'0' lucid
    zi light zsh-users/zsh-history-substring-search
    zi ice wait'0' lucid
    zi light zsh-vi-more/vi-increment
    zi ice wait'0' lucid
    zi light zdharma-continuum/fast-syntax-highlighting
    zi ice wait'0' lucid
    zi light MichaelAquilina/zsh-you-should-use
    zi ice wait'0' lucid silent atinit'ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT=true'
    zi light kutsan/zsh-system-clipboard
    zi ice wait'0' lucid atload'zicompinit'
    zi light zsh-users/zsh-completions
    zi snippet https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh


    ls_on() {
        chpwd() {
            emulate -L zsh
            ls
        }
    }

    ls_off() {
        chpwd() { }
    }

    ls_on

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
        [[ -r ~/.tool-versions ]] || return 1
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
    PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{7}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f%B$(git_prompt_info)%b%b >>> '
    RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b%F{9}%B $(get_python_version)%b%f%F{34}%B $(get_node_version)%b%f'

    ## use the vi navigation keys in menu completion
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history

    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down

    _yay_update() {
        LBUFFER="yay -Syu"
        RBUFFER=""
        zle accept-line
    }

    zle -N _yay_update
    bindkey -M vicmd '^[[15~' _yay_update
    bindkey -M viins '^[[15~' _yay_update
else
    PROMPT='%B%F{blue}%2~%f%b >>> '
    RPS1=''

    bindkey -v
    bindkey -M viins "^?" backward-delete-char

    autoload -Uz add-zsh-hook
    autoload -Uz add-zle-hook-widget

    vi-precmd () {
        echo -n "\e[6 q"
    }

    vi-line-pre-redraw () {
        case "$KEYMAP" in
            v*) echo -n "\e[2 q" ;;
            *) echo -n "\e[6 q" ;;
        esac
    }
    add-zsh-hook precmd vi-precmd
    add-zle-hook-widget line-pre-redraw vi-line-pre-redraw

    export KEYTIMEOUT=10
fi

[[ -z "$LS_COLORS" ]] && (( $+commands[dircolors] )) && eval "$(dircolors -b)"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

setopt extendedhistory
setopt hist_ignore_dups
setopt histignorealldups
setopt hist_ignore_space
setopt interactivecomments
setopt sharehistory
setopt auto_cd
setopt multios
setopt prompt_subst
setopt auto_pushd
setopt pushd_minus
setopt cdable_vars

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

bindkey -r -M vicmd '\ec'
bindkey -r -M viins '\ec'

fzf-open-file-in-vim-widget() {
    local value=$(__fsel)
    zle reset-prompt
    if [[ -n $value ]]; then
        LBUFFER="vim $value"
        zle accept-line
    fi
}
zle     -N            fzf-open-file-in-vim-widget
bindkey -M vicmd '^F' fzf-open-file-in-vim-widget
bindkey -M viins '^F' fzf-open-file-in-vim-widget

bindkey -M vicmd '^P' fzf-cd-widget
bindkey -M viins '^P' fzf-cd-widget
