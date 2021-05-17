if [ "$ASDF_ENABLED" = "true" ]; then
    __setup_asdf() {
        eval "local VERSION=\$ASDF_$(tr '[a-z]' '[A-Z]' <<< $1)_VERSION"
        [ -e $ASDF_DIR/plugins/$1 ] || asdf plugin add $1 || {
            echo "plugin could not be added"
            return 1
        }
        [ -z "$VERSION" ] && return 0
        [ -e $ASDF_DIR/installs/$1/$VERSION ] && return 0
        echo "$1 version '$VERSION' is not present, trying to install ..."
        asdf install $1 "$VERSION" || {
            echo "$1 version '$VERSION' not found"
            return 1
        }
    }
    if [ -e $HOME/.asdf ] || git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf; then
        . $HOME/.asdf/asdf.sh
        for L in $ASDF_ENABLED_PLUGINS; do
            __setup_asdf $L
        done
    fi
fi
