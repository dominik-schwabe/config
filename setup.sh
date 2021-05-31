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
echo -n "redshift config "

if LOCATION=$(curl -sL https://ipinfo.io/loc); then
    LAT=$(echo $LOCATION | cut -f1 -d,)
    LON=$(echo $LOCATION | cut -f2 -d,)
echo "[redshift]
temp-day=6500
temp-night=2700
location-provider=manual
adjustment-method=vidmode

[manual]
lat=$LAT
lon=$LON" > "$HOME/.config/redshift.conf"
    echo -e "${GREEN}success${RESET}"
else
    echo -e "${RED}failure${RESET}"
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
echo -n "generated config "
GENERATED_PATH="$HOME/.genrc"
TEMP_FILE=$(mktemp)
echo "FILE 0
NORMAL 0
RESET 0
DIR 01;34
LINK 01;36
MULTIHARDLINK 00
FIFO 40;33
SOCK 01;35
DOOR 01;35
BLK 40;33;01
CHR 40;33;01
ORPHAN 40;31;01
MISSING 00
SETUID 37;41
SETGID 30;43
CAPABILITY 30;41
STICKY_OTHER_WRITABLE 30;42
OTHER_WRITABLE 34;42
STICKY 37;44
EXEC 01;32" > $TEMP_FILE
curl -sL https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS | sed '/^\(FILE\|NORMAL\|RESET\|DIR\|LINK\|MULTIHARDLINK\|FIFO\|SOCK\|DOOR\|BLK\|CHR\|ORPHAN\|MISSING\|SETUID\|SETGID\|CAPABILITY\|STICKY_OTHER_WRITABLE\|OTHER_WRITABLE\|STICKY\|EXEC\)\(\s.*\)\?$/d' >> $TEMP_FILE
sed -i "s/\b38;5;074;1\b/38;5;127/g" $TEMP_FILE # js
sed -i "s/\b38;5;40\b/01;31/g" $TEMP_FILE # archive
sed -i "s/\b38;5;81\b/38;5;40/g" $TEMP_FILE # c
sed -i "s/\b38;5;110\b/38;5;208/g" $TEMP_FILE # h
sed -i "s/\b38;5;184\b/38;5;30/g" $TEMP_FILE # tex
dircolors -b $TEMP_FILE > $GENERATED_PATH
rm $TEMP_FILE
echo -e "${GREEN}success${RESET}"
echo
echo -n "custom config "
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

