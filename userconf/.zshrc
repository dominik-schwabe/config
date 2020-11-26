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
    COMPLETION_NAME=$(basename $1)
    COMPLETION_PATH=$ZSH_COMPLETIONS_DIR/$COMPLETION_NAME
    if [[ ! -r $COMPLETION_PATH ]]; then
        echo "downloading $COMPLETION_NAME"
        command -v curl 2>&1 >/dev/null && curl --create-dirs -sfLo $COMPLETION_PATH $1
    fi
}

download_completion https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pip/_pip

COMPLETION_WAITING_DOTS="true"
bgnotify_threshold=5

# plugins
source "$HOME/.zinit/bin/zinit.zsh"
zinit light "dominik-schwabe/vi-mode.zsh"
zinit snippet OMZL::theme-and-appearance.zsh
zinit snippet OMZL::completion.zsh
zinit ice wait'0' lucid
zinit snippet OMZL::directories.zsh
zinit ice wait'0' lucid
zinit snippet OMZL::git.zsh
zinit ice wait'0' lucid
zinit snippet OMZL::functions.zsh
zinit ice wait'0' lucid
zinit snippet OMZP::git
zinit ice wait'0' lucid
zinit snippet OMZP::bgnotify
zinit ice wait'0' lucid
zinit snippet OMZP::tmuxinator
zinit ice wait'0' lucid
zinit snippet OMZP::kubectl
zinit ice wait'0' lucid
zinit snippet OMZP::pip
zinit ice wait'0' lucid
zinit light "zsh-users/zsh-history-substring-search"
zinit ice wait'0' lucid
zinit light "ael-code/zsh-colored-man-pages"
zinit ice wait'0' lucid
zinit light "voronkovich/gitignore.plugin.zsh"
zinit ice wait'0' lucid
zinit light "mattberther/zsh-pyenv"
zinit ice wait'0' lucid
zinit light "zsh-vi-more/vi-increment"
zinit ice wait'0' lucid
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

zstyle ':completion:*:default' list-colors "di=1;34" "ln=1;36" "so=1;32" "pi=33" "ex=1;32" "bd=34;46" "cd=1;33" "su=30;41" "sg=30;46" "tw=30;42" "ow=30;43"

autoload -Uz compinit && compinit -i

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

## use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

function chpwd() {
    emulate -L zsh
    ls
}

unset correctall

# theme
DEFAULT_COLOR="2"
ROOT_COLOR="214"
SSH_COLOR="161"

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

function my_git_prompt_info() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    GIT_STATUS=$(git_prompt_status)
    [[ $GIT_STATUS ]] && GIT_STATUS=" $GIT_STATUS"
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{178}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f$(my_git_prompt_info)%b >>> '

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{3}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"
RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b'
# theme end

setopt interactivecomments
setopt noextendedhistory
setopt nosharehistory

exit_zsh() { exit }
zle -N exit_zsh
bindkey -M viins '^D' exit_zsh
bindkey -M vicmd '^D' exit_zsh

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
