[[ -r "$HOME/.envrc" ]] && . "$HOME/.envrc"
[[ -r "$HOME/.genrc" ]] && . "$HOME/.genrc"
[[ -r "$HOME/.aliasrc" ]] && . "$HOME/.aliasrc"

[[ -r "$HOME/.shell_plugins/asdf/plugin.sh" ]] && . "$HOME/.shell_plugins/asdf/plugin.sh"

export HISTFILE="$HOME/.zsh_history"
export HISTORY_IGNORE="(ls|mv|cp|rm|cd|z|cat|pwd|td|te|o|vim|ovim|novim|rg|fd|ga|gco|ytdl|file|whereis) *"

# +++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++ completion ++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++
COMPLETION_WAITING_DOTS=true
zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
# setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

expand-or-complete-with-dots() {
    COMPLETION_WAITING_DOTS="%F{red}…%f"
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
# Set the function as the default tab completion widget
bindkey -M emacs "^I" expand-or-complete-with-dots
bindkey -M viins "^I" expand-or-complete-with-dots
bindkey -M vicmd "^I" expand-or-complete-with-dots
# -------------------------------------------
# --------------- completion ----------------
# -------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++ fzf ++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-}" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  echo "fzf $@"
}

fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}

fzf-history-widget() {
  local query selected num list results array
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  list=$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }')
  query=$(sed ':a;N;$!ba;s/\n/\\n/g' <<< "$LBUFFER$RBUFFER")
  results=$(FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --print-query --bind=ctrl-s:toggle-sort,ctrl-z:ignore,esc:print-query ${FZF_CTRL_R_OPTS-} --query='$query' +m" fzf <<< "$list")
  results=a$results # empty string can fail the split on \n
  if [[ $? == 0 ]]; then
    IFS=$'\n' read -d '' -r -A array <<< "$results"
    array[1]=${array[1]:1} # remove "a"
    if [[ $#array == 3 ]]; then
      selected=($(echo "${array[2]}"))
      num=$selected[1]
      zle vi-fetch-history -n $num
    else
      query="${array[1]}"
      LBUFFER="${query}"
      RBUFFER=""
    fi
  fi
  zle reset-prompt
}

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}

fzf-open-file() {
    local value=$(__fsel)
    zle reset-prompt
    if [[ -n $value ]]; then
      LBUFFER="o $value"
      zle accept-line
    fi
}

fzf-media() {
  local cmd="cat $HOME/.media 2>/dev/null"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local media="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$media" ]]; then
    zle redisplay
  else
    zle reset-prompt
    LBUFFER="o $media"
    zle accept-line
  fi
}

zle     -N            fzf-history-widget
bindkey -M vicmd '^A' fzf-history-widget
bindkey -M viins '^A' fzf-history-widget

zle     -N            fzf-open-file
bindkey -M vicmd '^F' fzf-open-file
bindkey -M viins '^F' fzf-open-file

zle     -N            fzf-media
bindkey -M vicmd '^O' fzf-media
bindkey -M viins '^O' fzf-media

zle     -N            fzf-cd-widget
bindkey -M vicmd '^P' fzf-cd-widget
bindkey -M viins '^P' fzf-cd-widget
# -------------------------------------------
# ------------------ fzf --------------------
# -------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++ vi mode +++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++
echo -n "\e[6 q"
autoload -Uz add-zsh-hook
autoload -Uz add-zle-hook-widget
bindkey -v

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

# Reduce esc delay
export KEYTIMEOUT=${KEYTIMEOUT:-10}

# fix backspace
bindkey -M viins "^?" backward-delete-char

# textobjects
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# omz sudo plugin bound to f1 instead of esc
__sudo-replace-buffer() {
    local old=$1 new=$2 space=${2:+ }
    if [[ ${#LBUFFER} -le ${#old} ]]; then
        RBUFFER="${space}${BUFFER#$old }"
        LBUFFER="${new}"
    else
        LBUFFER="${new}${space}${LBUFFER#$old }"
    fi
}

sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

    # Save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi

    if [[ $BUFFER = sudo\ * ]]; then
        __sudo-replace-buffer "sudo" ""
    else
        LBUFFER="sudo $LBUFFER"
    fi

    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N sudo-command-line

bindkey -M vicmd '^[OP' sudo-command-line
bindkey -M viins '^[OP' sudo-command-line
bindkey -M vicmd '^[[[A' sudo-command-line
bindkey -M viins '^[[[A' sudo-command-line
# sudo plugin end

# some useless keybindings
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word
# -------------------------------------------
# ------------------ vi mode ----------------
# -------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++ zoxide +++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --no-cmd)"
    function z() {
        __zoxide_zi "$@"
    }
fi
# -------------------------------------------
# ------------------ zoxide -----------------
# -------------------------------------------

auto_ls_toggle() {
    if functions chpwd &>/dev/null; then
        unset -f chpwd
    else
        chpwd() {
            emulate -L zsh
            ls
        }
    fi
}

zle -N auto_ls_toggle
bindkey -M viins '^K' auto_ls_toggle
bindkey -M vicmd '^K' auto_ls_toggle

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

## use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

_yay_update() {
    LBUFFER="yay -Syu --noconfirm"
    RBUFFER=""
    zle accept-line
}

zle -N _yay_update
bindkey -M vicmd '^[[15~' _yay_update
bindkey -M viins '^[[15~' _yay_update

fpath+=$HOME/.zfunc
fpath+=$HOME/.zsh-completions

if autoload -Uz compinit bashcompinit; then
    compinit -d $HOME/.zcompdump2
    bashcompinit
fi

if [[ -z "$MINIMAL_CONFIG" ]]; then
    auto_ls_toggle

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
            [[ "$ref" == *'ref HEAD is not a symbolic ref' ]] && echo " %F{14}no branch%f"
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
    COMMON_PROMPT='%B%F{'$PROMPT_COLOR'}%n%f%F{7}@%F{'$PROMPT_COLOR'}%m %F{blue}%2~%f%B$(git_prompt_info)%b%b '
    ACTIVE_PROMPT=${COMMON_PROMPT}$'\e[5m>>>\e[0m '
    DONE_PROMPT=${COMMON_PROMPT}'>>> '
    PROMPT=$DONE_PROMPT
    RPS1='%(?..%F{1}%B%?%b%f )% %w %B%F{11}%T%f%b%F{9}%B $(get_python_version)%b%f%F{34}%B $(get_node_version)%b%f'

    # show-inactive-prompt() {
    #   PROMPT=$DONE_PROMPT
    #   zle reset-prompt
    #   PROMPT=$ACTIVE_PROMPT
    # }

    # change-prompt-and-accept-line() {
    #   show-inactive-prompt
    #   zle accept-line
    # }

    # zle -N change-prompt-and-accept-line
    # bindkey "^M" change-prompt-and-accept-line

    load_plugin() {
        local URL=$1
        local NAME=$(basename $URL)
        local DEST=$HOME/.zsh-plugins/$NAME
        [[ ! -d $DEST ]] && (( $+commands[git] )) && git clone $URL $DEST
        [[ -d $DEST ]] && source $DEST/$NAME.plugin.zsh
    }

    load_plugin https://github.com/zdharma-continuum/fast-syntax-highlighting
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
