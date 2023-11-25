[[ -r ~/.envrc ]] && . ~/.envrc
[[ -r ~/.genrc ]] && . ~/.genrc
[[ -r ~/.aliasrc ]] && . ~/.aliasrc
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

[[ -r "$HOME/.shell_plugins/asdf/plugin.sh" ]] && . "$HOME/.shell_plugins/asdf/plugin.sh"

shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -u autocd

RESET="\[\033[0m\]"

BLACK="\[\033[0;30m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"

BBLACK="\[\033[1;30m\]"
BRED="\[\033[1;31m\]"
BGREEN="\[\033[1;32m\]"
BYELLOW="\[\033[1;33m\]"
BBLUE="\[\033[1;34m\]"
BPURPLE="\[\033[1;35m\]"
BCYAN="\[\033[1;36m\]"
BWHITE="\[\033[1;37m\]"

IBLACK="\[\033[0;90m\]"
IRED="\[\033[0;91m\]"
IGREEN="\[\033[0;92m\]"
IYELLOW="\[\033[0;93m\]"
IBLUE="\[\033[0;94m\]"
IPURPLE="\[\033[0;95m\]"
ICYAN="\[\033[0;96m\]"
IWHITE="\[\033[0;97m\]"

BIBLACK="\[\033[1;90m\]"
BIRED="\[\033[1;91m\]"
BIGREEN="\[\033[1;92m\]"
BIYELLOW="\[\033[1;93m\]"
BIBLUE="\[\033[1;94m\]"
BIPURPLE="\[\033[1;95m\]"
BICYAN="\[\033[1;96m\]"
BIWHITE="\[\033[1;97m\]"

PROMPT_COLOR=$BGREEN
[[ "$UID" == "0" ]] && PROMPT_COLOR=$BRED
[[ "$SSH_TTY" ]] && PROMPT_COLOR=$BYELLOW

export PS1="${PROMPT_COLOR}\u${BWHITE}@${PROMPT_COLOR}\h ${BBLUE}\w ${IYELLOW}\A ${BRED}\$(_RET=\$?; [ \"\$_RET\" = 0 ] || echo \"\$_RET \")${WHITE}>>>${RESET} "

# zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash --no-cmd)"
  function z() {
    __zoxide_zi "$@"
  }
fi

# fzf
if command -v fzf &>/dev/null && [[ $- =~ i ]]; then
  __fzf_select__() {
    local cmd opts
    cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
    result=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@")
    ret=$?
    while read -r item; do
      printf '%q ' "$item" # escape special chars
    done <<<"$result"
    return $ret
  }

  __fzfcmd() {
    [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
      echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
  }

  fzf-file-widget() {
    result=$(__fzf_select__ "$@")
    if [[ $? == 0 ]]; then
      local selected="o $result"
      READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
      READLINE_POINT=$((READLINE_POINT + ${#selected}))
    fi
  }

  __fzf_cd__() {
    local cmd opts dir
    cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} +m"
    dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)) && builtin cd -- "$dir"
  }

  __fzf_history__() {
    local output opts script
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
    output=$(
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$script" |
        FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }

  bind -m vi-command -x '"\C-f": fzf-file-widget'
  bind -m vi-insert -x '"\C-f": fzf-file-widget'

  bind -m vi-command -x '"\C-a": __fzf_history__'
  bind -m vi-insert -x '"\C-a": __fzf_history__'

  bind -m vi-command -x '"\C-p": __fzf_cd__'
  bind -m vi-insert -x '"\C-p": __fzf_cd__'
fi
