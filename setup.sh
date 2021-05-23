#!/usr/bin/env bash

GREEN="\e[32m"
BLUE="\e[34m"
MAGENTA="\e[35m"
RED="\e[31m"
RESET="\e[0m"

CURRPATH="$(pwd)/$(dirname $0)"
cd $CURRPATH

while getopts "f" o; do
    [ $o == "f" ] && FORCE="-f"
done

[ -e $HOME/bin ] || mkdir $HOME/bin

echo "bin setup"
./create_symlink.sh $FORCE $CURRPATH/bin $HOME/.bin
echo
echo "config setup"
for file in $(find userconf -not -type d -printf '%P '); do
    ./create_symlink.sh $FORCE $CURRPATH/userconf/$file $HOME/$file
done
echo
echo -n "redshift config"

if LOCATION=$(curl -sL https://ipinfo.io/loc); then
    LAT=$(echo $LOCATION | cut -f1 -d,)
    LON=$(echo $LOCATION | cut -f2 -d,)
echo "[redshift]
temp-day=6500
temp-night=3500
location-provider=manual
adjustment-method=vidmode

[manual]
lat=$LAT
lon=$LON" > "$HOME/.config/redshift.conf"
    echo -e " ${GREEN}success${RESET}"
else
    echo -e " ${RED}failure${RESET}"
fi
echo
echo "tool setup"
for file in $CURRPATH/tools/*; do
    echo -n "$(basename $file)"
    $file
    RET=$?
    [ "$RET" = 3 ] && echo -e " ${MAGENTA}not supported${RESET}"
    [ "$RET" = 2 ] && echo -e " ${BLUE}exists${RESET}"
    [ "$RET" = 1 ] && echo -e " ${RED}failure${RESET}"
    [ "$RET" = 0 ] && echo -e " ${GREEN}success${RESET}"
done
echo
echo "folder links"
./create_symlink.sh $CURRPATH/shell_plugins $FORCE $HOME/.shell_plugins
echo
echo "custom config"
CUSTOM_PATH="$HOME/.customrc"
if [ -e "$CUSTOM_PATH" ]; then
    if ! [ -d "$CUSTOM_PATH" ]; then
        echo -e "${BLUE}exists${RESET}"
    else
        echo -e "${RED}failure${RESET}"
    fi
fi
if ! [ -e "$CUSTOM_PATH" ]; then
    cp ./customrc "$CUSTOM_PATH"
    echo -e "${GREEN}success${RESET}"
fi
