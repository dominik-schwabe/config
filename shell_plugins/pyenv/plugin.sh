if [ "$ENABLE_PYENV" = "true" ]; then
    [ -z "$PYENV_ROOT" ] && export PYENV_ROOT="$HOME/.pyenv"

    command -v pyenv &>/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    command -v pyenv &>/dev/null || {
        echo "installing pyenv ..."
        local PYENV_INSTALL_URL="https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer"
        PYENV_INSTALL_SCRIPT=$(curl -fsSL $PYENV_INSTALL_URL 2>/dev/null)  \
        || PYENV_INSTALL_SCRIPT=$(wget -qO- $PYENV_INSTALL_URL 2>/dev/null) \
        || {echo "curl or wget required to install pyenv"; return 1}
        bash -s -- <<< $PYENV_INSTALL_SCRIPT || return 1
        unset PYENV_INSTALL_SCRIPT
    }
    command -v pyenv &>/dev/null && {
        eval "$(pyenv init --path)"
        eval "$(pyenv init - --no-rehash)"
        eval "$(pyenv virtualenv-init -)"
    }
fi
