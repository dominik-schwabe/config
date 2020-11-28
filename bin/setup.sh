#!/usr/bin/env bash

THISPATH="$(pwd)/$(dirname $0)"

FORCE=""
while getopts "f" o
do
    if [ $o == "f" ]
    then
        FORCE="-f"
    fi
done

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

mkconfig() {
    SRCPATH=${THISPATH}/$1
    DESTPATH=${HOME}/bin/$1
    mkdir -p $(dirname $DESTPATH)
    ln -s $FORCE $SRCPATH $DESTPATH &> /dev/null &&
        echo -e "${GREEN}success${RESET} creating symlink $DESTPATH" ||
        echo -e "${RED}failure${RESET} creating symlink $DESTPATH (use -f to force creation)"
}

for file in $THISPATH/*; do
    file=$(basename $file)
    [[ "$file" != "setup.sh" ]] && mkconfig $file
done
