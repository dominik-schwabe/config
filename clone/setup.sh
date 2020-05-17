#!/bin/bash

ORANGE="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

cloneupdate() {
    echo -e "${BLUE}clone ${RESET}$1 ${ORANGE}to${RESET} $2"
    GITNAME=$1
    GITPATH=https://github.com/$1
    DESTDIR=$2
    git clone $GITPATH $DESTDIR &> /dev/null
    if [ $?  != 0 ]
    then
        echo -e "${RED}pull${RESET} from $1 ${ORANGE}to${RESET} $2"
        cd $2 &> /dev/null
        git pull &> /dev/null
    fi
}

git &> /dev/null
if [ $? != 1 ]
then
    exit 1
fi

cloneupdate "tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"