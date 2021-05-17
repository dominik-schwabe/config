if [ "$ENABLE_N" = "true" ]; then
    export N_PREFIX="$HOME/.n"
    export PATH="$N_PREFIX/bin:$PATH"
    _install_n() {
        if ! npm install -g n 2>/dev/null; then
            if command -v curl &>/dev/null; then
                curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n 2>/dev/null | bash -s -- "$NODE_VERSION"
                npm install -g n
            else
                echo "curl or npm needs to be installed"
                return 1
            fi
        fi
        return 0
    }

    if command -v n &>/dev/null || _install_n; then
        [ -n "$NODE_VERSION" -a "$(node --version 2>/dev/null)" != "$NODE_VERSION" ] && n install "$NODE_VERSION"
    fi
fi
