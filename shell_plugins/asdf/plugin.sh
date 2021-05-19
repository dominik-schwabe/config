if [ "$ASDF_ENABLED" = "true" ]; then
    _get_adsf_versions() {
        [ -r $HOME/.tool-versions ] || return 1
        local VERSIONS=$(sed -n -e "/^$1\s/{s/^$1\s//p;q}" < $HOME/.tool-versions)
        [ -z "$VERSIONS" ] && return 1
        echo $VERSIONS
    }

    __setup_asdf() {
        eval "local VERSIONS=\$$(tr '[a-z]' '[A-Z]' <<< $1)_VERSION"
        [ -e $ASDF_DIR/plugins/$1 ] || asdf plugin add $1 || {
            echo "plugin could not be added"
            return 1
        }
        [ -z "$VERSIONS" -o "$(_get_adsf_versions $1)" = "$VERSIONS" ] && return 0
        VERSIONS=($(echo $VERSIONS))
        for VERSION in $VERSIONS; do
            [ -e $ASDF_DIR/installs/$1/$VERSION ] && continue
            echo "$1 version '$VERSION' is not present, trying to install ..."
            asdf install $1 "$VERSION" || {
                echo "$1 version '$VERSION' not found"
                return 1
            }
        done
        asdf global $1 $(echo $VERSIONS)
    }

    export ASDF_DIR="$HOME/.asdf"
    if [ -e $ASDF_DIR ] || git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR; then
        PATH="$ASDF_DIR/bin:$PATH"
        for L in $ASDF_ENABLED_PLUGINS; do
            __setup_asdf $L
        done
        if [ "$ASDF_TURBO" = "true" ]; then
            for L in $ASDF_ENABLED_PLUGINS; do
                VERSIONS=($(echo $(_get_adsf_versions $L)))
                for VERSION in $VERSIONS; do
                    _VERSION_PATH="$ASDF_DIR/installs/$L/$VERSION/bin"
                    if [ -z "$ASDF_TURBO_PATH" ]; then
                        ASDF_TURBO_PATH=$_VERSION_PATH
                    else
                        ASDF_TURBO_PATH="$ASDF_TURBO_PATH:$_VERSION_PATH"
                    fi
                done
            done
            [ -n "$ASDF_TURBO_PATH" ] && PATH="$ASDF_TURBO_PATH:$PATH"
        else
            PATH="$ASDF_DIR/shims:$PATH"
        fi
    fi
fi
