# clone pluginmanager if not exist
if ! [ -d ~/.zinit/bin ]; then
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi

if [[ -r ~/.envrc ]]; then
    . ~/.envrc
fi

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

[ -d $NODE_PATH ] || mkdir -p $NODE_PATH

ZSH_COMPLETIONS_DIR=~/.zsh-completions
[ -d $ZSH_COMPLETIONS_DIR ] || mkdir $ZSH_COMPLETIONS_DIR
fpath+="$ZSH_COMPLETIONS_DIR"

download_completion() {
    local COMPLETION_NAME=$(basename $1)
    COMPLETION_NAME=${COMPLETION_NAME:1}
    COMPLETION_NAME=${2-$COMPLETION_NAME}
    local COMPLETION_PATH=$ZSH_COMPLETIONS_DIR/_$COMPLETION_NAME
    if [[ ! -r $COMPLETION_PATH ]] && command -v curl 2>&1 >/dev/null; then
        echo "downloading $COMPLETION_NAME"
        curl --create-dirs -sfLo $COMPLETION_PATH $1
        local NAME_IN_COMPDEF=$(sed -n "/^\s*#\?compdef/{p;q}" $COMPLETION_PATH | sed "s/\s/\n/g" | sed -n "/${COMPLETION_NAME}/{p;q}")
        if [ -z "$NAME_IN_COMPDEF" ]; then
            sed -i "/^\s*#\?compdef/d" $COMPLETION_PATH
            sed -i "1 i\\#compdef ${COMPLETION_NAME}" $COMPLETION_PATH
        fi
    fi
}

command_completion() {
    if [[ ! -r $ZSH_COMPLETIONS_DIR/_$1 ]] && command -v $1 2>&1 >/dev/null; then
        echo "generating completion '$@'"
        $@ > $ZSH_COMPLETIONS_DIR/_$1
    fi
}

download_completion https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pip/_pip
download_completion https://raw.githubusercontent.com/iboyperson/zsh-pipenv/master/_pipenv
download_completion https://raw.githubusercontent.com/AlexaraWu/zsh-completions/master/src/_7z 7z
download_completion https://gist.githubusercontent.com/ssh0/436e906765dfe8d1b3d6/raw/f4a75bc5ed90d1c8217baa5c6cef7543a3c6d04c/youtube-dl_completion.zsh youtube-dl
download_completion https://raw.githubusercontent.com/pwmt/zathura/develop/data/zsh-completion.in vpdf
command_completion kubectl completion zsh

COMPLETION_WAITING_DOTS="true"
bgnotify_threshold=5
export KEYTIMEOUT=15

# plugins
source "$HOME/.zinit/bin/zinit.zsh"
zinit light "dominik-schwabe/vi-mode.zsh"
zinit snippet OMZL::theme-and-appearance.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::git.zsh
zinit ice wait'0' lucid
zinit snippet OMZP::git
zinit ice wait'0' lucid
zinit snippet OMZP::pip
zinit ice wait'0' lucid
zinit snippet OMZP::gitignore
zinit ice wait'0' lucid
zinit light "t413/zsh-background-notify"
zinit ice wait'0' lucid
zinit light "zsh-users/zsh-history-substring-search"
zinit ice wait'0' lucid
zinit light "ael-code/zsh-colored-man-pages"
zinit ice wait'0' lucid
zinit light "mattberther/zsh-pyenv"
zinit ice wait'0' lucid
zinit light "zsh-vi-more/vi-increment"
zinit ice wait'!0' lucid
zinit light "dominik-schwabe/zsh-fnm"
zinit ice wait'0' lucid
zinit light "zdharma/fast-syntax-highlighting"
zinit ice wait'0' lucid
zinit light "MichaelAquilina/zsh-you-should-use"
zinit ice wait'0' lucid
zinit light "kutsan/zsh-system-clipboard"
zinit ice wait'0' lucid
zinit light "akarzim/zsh-docker-aliases"
zinit ice wait'0' lucid
zinit light "zsh-users/zsh-completions"
#zinit light "lukechilds/zsh-better-npm-completion"
#zinit light "zdharma/history-search-multi-word"
#zinit light "zsh-users/zsh-autosuggestions"

zstyle ':completion:*:default' list-colors $LS_COLORS

autoload -Uz compinit && compinit -i

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

DEFAULT_COLOR=${DEFAULT_COLOR:-green}
SSH_COLOR=${SSH_COLOR:-blue}
ROOT_COLOR=${ROOT_COLOR:-red}

if [[ $SSH_TTY ]]; then
    PROMPT_COLOR=$SSH_COLOR
elif [[ $UID == 0 ]]; then
    PROMPT_COLOR=$ROOT_COLOR
else
    PROMPT_COLOR=$DEFAULT_COLOR
fi

my_git_prompt_info() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    GIT_STATUS=$(git_prompt_status)
    [[ $GIT_STATUS ]] && GIT_STATUS=" $GIT_STATUS"
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{7}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f$(my_git_prompt_info)%b >>> '

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{3}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"
RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b%F{9}%B${PYENV_VERSION+ $PYENV_VERSION}%b%f%F{34}%B${ZSH_FNM_NODE_VERSION+ $ZSH_FNM_NODE_VERSION}%b%f'
# theme end

setopt hist_ignore_dups hist_ignore_space interactivecomments noextendedhistory nosharehistory

exit_zsh() { exit }
zle -N exit_zsh
bindkey -M viins '^D' exit_zsh
bindkey -M vicmd '^D' exit_zsh

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

expand-alias() {
	zle _expand_alias
}
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

docker-tags() {
    curl --silent --get "https://registry.hub.docker.com/v1/repositories/$1/tags" | jq -r '.[].name'
}
