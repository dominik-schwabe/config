#!/usr/bin/env bash

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

CURRPATH="$(pwd)/$(dirname $0)"
cd $CURRPATH

while getopts "f" o; do
    [ $o == "f" ] && FORCE="-f"
done

echo "bin setup"
[ -e $HOME/bin ] || mkdir $HOME/bin
for file in $CURRPATH/bin/*; do
    ./create_symlink.sh $FORCE $file $HOME/bin/$(basename $file)
done
echo
echo "config setup"
for file in $(find userconf -not -type d -printf '%P '); do
    ./create_symlink.sh $FORCE $CURRPATH/userconf/$file $HOME/$file
done
echo
echo "tool setup"
for file in $CURRPATH/tools/*; do
    echo -n "$(basename $file)"
    $file
    RET=$?
    [ "$RET" = 2 ] && echo -e " ${BLUE}exists${RESET}"
    [ "$RET" = 1 ] && echo -e " ${RED}failure${RESET}"
    [ "$RET" = 0 ] && echo -e " ${GREEN}success${RESET}"
done
echo
echo "folder links"
./create_symlink.sh $FORCE $HOME/.shell_plugins $CURRPATH/shell_plugins
