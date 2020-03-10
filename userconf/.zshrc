if ! [ -d ~/.zinit/bin ]; then
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.zshplugins/oh-my-zsh

#ZSH_THEME="agnoster"
#ZSH_THEME="alanpeabody"
#ZSH_THEME="essembeh"
#ZSH_THEME="gentoo"
#ZSH_THEME="jaischeema"
#ZSH_THEME="clean"
#ZSH_THEME="lukerandall"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

bgnotify_threshold=5
plugins=(git pip colored-man-pages sudo history-substring-search bgnotify z systemd tmuxinator)
source $ZSH/oh-my-zsh.sh

VI_MODE_CURSOR_INSERT='\e[2 q'
VI_MODE_CURSOR_NORMAL='\e[6 q'


# pluins
source "$HOME/.zinit/bin/zinit.zsh"
zinit light "zdharma/fast-syntax-highlighting"
zinit light "MichaelAquilina/zsh-you-should-use"
zinit light "kutsan/zsh-system-clipboard"
zinit light "madKuchenbaecker/vi-mode.zsh"
zinit light "akarzim/zsh-docker-aliases"
#zinit light "robbyrussell/oh-my-zsh"
#zinit light "zdharma/history-search-multi-word"
#zinit plugin light "zsh-users/zsh-autosuggestions"
#zinit light "zsh-users/zsh-completions"



autoload -Uz compinit && compinit -i

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

unset correctall

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

if [[ -r ~/.envrc ]]; then
    . ~/.envrc
fi

bindkey "^?" backward-delete-char

# fix interaction of plugins: sudo vi-mode.zsh
export KEYTIMEOUT=0

setopt noextendedhistory
setopt nosharehistory

if [ -z $ZSH_THEME ]
then
    function my_git_prompt_info() {
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        GIT_STATUS=$(git_prompt_status)
        if [[ -n $GIT_STATUS ]]
        then
            GIT_STATUS=" $GIT_STATUS"
        else
            GIT_STATUS=" ✔"
        fi
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
    }

    PROMPT='%{$fg_bold[green]%}%n%F{#cccc00}@%f%{$fg_bold[green]%}%m%{$reset_color%} %{$fg_bold[blue]%}%2~%{$reset_color%} $(my_git_prompt_info)%{$reset_color%}%B»%b '

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%} "
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
    ZSH_THEME_GIT_PROMPT_ADDED="+"
    ZSH_THEME_GIT_PROMPT_MODIFIED="*"
    ZSH_THEME_GIT_PROMPT_RENAMED="~"
    ZSH_THEME_GIT_PROMPT_DELETED="!"
    ZSH_THEME_GIT_PROMPT_UNMERGED="?"
fi

RPS1='%(?..%B%F{#FF0000}%?%b ✗ %f)% %w %B%F{yellow}%T%f%b'
