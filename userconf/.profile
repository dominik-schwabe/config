export VISUAL=nvim
export EDITOR=nvim
export PAGER=less
export BROWSER=brave
export TERMINAL="alacritty -e"

export HISTFILE=~/.sh_history
export HISTSIZE=1500
export SAVEHIST=1500
export HISTFILESIZE=1500
export HISTCONTROL=ignoreboth

export NODE_PATH="$HOME/.local/lib/node_modules"
export NPM_CONFIG_PREFIX="$HOME/.local"

export PIPENV_MAX_DEPTH=100

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

add_path() {
	if [[ :$PATH: != *:$1:* ]]; then
		export PATH="$1:$PATH"
	fi
}

add_path "$HOME/.cargo/bin"
add_path "$HOME/local/bin"
add_path "$HOME/.local/bin"
add_path "$HOME/.bin"
add_path "$HOME/bin"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"


# vi: ft=sh
