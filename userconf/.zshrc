# Path to your oh-my-zsh installation.
export ZSH=$HOME/.zshplugins/oh-my-zsh

#ZSH_THEME="agnoster"
#ZSH_THEME="alanpeabody"
#ZSH_THEME="essembeh"
#ZSH_THEME="gentoo"
#ZSH_THEME="jaischeema"
ZSH_THEME="lukerandall"

# Uncomment the following line to use case-sensitive completion.  CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
#HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
#DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
#export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
#DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
#DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
#DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
#DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
#HIST_STAMPS="mm/dd/yyyy"

bgnotify_threshold=5
plugins=(git pip colored-man-pages sudo history-substring-search bgnotify z)
source $ZSH/oh-my-zsh.sh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
#export LANG=en_US.UTF-8

# Compilation flags
#export ARCHFLAGS="-arch x86_64"

VI_MODE_CURSOR_INSERT='\e[2 q'
VI_MODE_CURSOR_NORMAL='\e[6 q'
### Added by Zplugin's installer
source "$HOME/.zplugin/bin/zplugin.zsh"
#zplugin light "robbyrussell/oh-my-zsh"
#zplugin light "zdharma/history-search-multi-word"
#zplugin light "zsh-users/zsh-autosuggestions"
zplugin light "zdharma/fast-syntax-highlighting"
zplugin light "zsh-users/zsh-completions"
zplugin light "MichaelAquilina/zsh-you-should-use"
zplugin light "kutsan/zsh-system-clipboard"
zplugin light "madKuchenbaecker/vi-mode.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin installer's chunk

autoload -U compinit && compinit

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

unset correctall

if [[ -r ~/.aliasrc ]]; then
    . ~/.aliasrc
fi

if [[ -r ~/.envrc ]]; then
    . ~/.envrc
fi

bindkey "^?" backward-delete-char
# fix interaction of plugins: sudo vi-mode.zsh
export KEYTIMEOUT=0