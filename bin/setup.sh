#!/bin/bash

CURRPATH="$(pwd)/$(dirname $0)"

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
    SRCPATH=${CURRPATH}/$1
    DESTPATH=${HOME}/bin/$2
    DESTDIR=$(dirname $DESTPATH)
    F=$3
    mkdir -p $DESTDIR
    ln -s $F $SRCPATH $DESTPATH &> /dev/null
    if [ $? -eq 0 ]
    then
        echo -e "${GREEN}success${RESET} creating symlink $DESTPATH"
    else
        echo -e "${RED}failure${RESET} creating symlink $DESTPATH (use -f to force creation)"
    fi
}

set \
    nolidswitch nolidswitch \
    nolidswitchtoggle nolidswitchtoggle \
    xvim xvim \

while :
do
    SRCDIR=$1
    shift &> /dev/null
    if [ $? -ne 0 ]
    then
        break
    fi
    DESTDIR=$1
    shift &> /dev/null
    if [ $? -ne 0 ]
    then
        break
    fi
    mkconfig $SRCDIR $DESTDIR $FORCE
done
