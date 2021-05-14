if [ "$ENABLE_FNM" = "true" ]; then
    _install_fnm() {
        local FNM_INSTALL_URL="https://fnm.vercel.app/install"
        FNM_INSTALL_SCRIPT=$(curl -fsSL $FNM_INSTALL_URL 2>/dev/null) \
        || FNM_INSTALL_SCRIPT=$(wget -qO- $FNM_INSTALL_URL 2>/dev/null) \
        || { echo "curl or wget required to install fnm"; return 1; }
        bash -s -- --skip-shell <<< $FNM_INSTALL_SCRIPT || return 1
        unset FNM_INSTALL_SCRIPT
        return 0
    }

    command -v fnm &>/dev/null || {
        export PATH=$HOME/.fnm:$PATH
        command -v fnm &>/dev/null || _install_fnm
    }

    eval "$(fnm env)"

    if [ -n "$FNM_VERSION" ]; then
        fnm use $FNM_VERSION &>/dev/null
        [ "$?" != "0" ] && fnm use system &>/dev/null
    else
        fnm use system &>/dev/null
    fi
fi
