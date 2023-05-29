[[ -r ~/.envrc ]] && . ~/.envrc
[[ -r ~/.genrc ]] && . ~/.genrc
[[ -r ~/.aliasrc ]] && . ~/.aliasrc
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

[[ -r "$HOME/.shell_plugins/asdf/plugin.sh" ]] && . "$HOME/.shell_plugins/asdf/plugin.sh"

shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -u autocd

RESET="\[\017\]"
RED="\[\033[31;1m\]"
GREEN="\[\033[32;1m\]"
YELLOW="\[\033[33;1m\]"
BLUE="\[\033[34;1m\]"
WHITE="\[\033[00m\]"
BOLDWHITE="\[\033[37;1m\]"

PROMPT_COLOR=$GREEN
[[ "$UID" == "0" ]] && PROMPT_COLOR=$RED
[[ "$SSH_TTY" ]] && PROMPT_COLOR=$YELLOW

export PS1="${PROMPT_COLOR}\u${BOLDWHITE}@${PROMPT_COLOR}\h ${BLUE}\w ${YELLOW}$(date +'%H:%M') ${RED}\$(_RET=\$?; [ \"\$_RET\" = 0 ] || echo \"\$_RET \")${WHITE}>>> ${RESET}"

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
    eval "$cmd" |
      FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@" |
      while read -r item; do
        printf '%q ' "$item" # escape special chars
      done
  }

  __fzfcmd() {
    [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
      echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
  }

  fzf-file-widget() {
    local selected="o $(__fzf_select__ "$@")"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
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
