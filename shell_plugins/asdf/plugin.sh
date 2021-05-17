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

    if [ -e $HOME/.asdf ] || git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf; then
        . $HOME/.asdf/asdf.sh
        for L in $ASDF_ENABLED_PLUGINS; do
            __setup_asdf $L
            VERSIONS=($(echo $(_get_adsf_versions $L)))
            for VERSION in $VERSIONS; do
                PATH="$ASDF_DIR/installs/$L/$VERSION/bin:$PATH"
            done
        done
        if [ "$ASDF_SPEED" = "true" ]; then
            for L in $ASDF_ENABLED_PLUGINS; do
                VERSIONS=($(echo $(_get_adsf_versions $L)))
                for VERSION in $VERSIONS; do
                    PATH="$ASDF_DIR/installs/$L/$VERSION/bin:$PATH"
                done
            done
        fi
    fi
fi
