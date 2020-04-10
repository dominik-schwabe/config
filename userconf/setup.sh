#!/usr/bin/bash

CURRPATH="$(pwd)/$(dirname $0)"
cd $CURRPATH

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
    DESTPATH=${HOME}/$2
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
    .vimrc .vimrc \
    .coc-settings.json .vim/coc-settings.json \
    .coc-settings.json .config/nvim/coc-settings.json \
    .bashrc .bashrc \
    .envrc .envrc \
    .toprc .toprc \
    .inputrc .inputrc \
    .rc.conf .config/ranger/rc.conf \
    .termite.conf .config/termite/config \
    .aliasrc .aliasrc \
    .i3config .config/i3/config \
    .i3pystatus.conf .config/i3/i3pystatus.conf \
    .init.vim .config/nvim/init.vim \
    .Xdefaults .Xdefaults \
    .xsession .xsession \
    .xsession .xsessionrc \
    .xinitrc .xinitrc \
    .bg.jpg .bg.jpg \
    .bg.png .bg.png \
    .zathurarc .config/zathura/zathurarc \
    .tmux.conf .tmux.conf \
    .zshrc .zshrc \
    .config.rasi .config/rofi/config.rasi \
    .picom.conf .config/picom.conf \
    .gitconfig .gitconfig \
    .Rprofile .Rprofile \
    .dunstrc .config/dunst/dunstrc \
    .gtkrc-3.0 .config/gtk-3.0/settings.ini \
    .gtkrc-2.0 .gtkrc-2.0 \
    .ipython_config.py .ipython/profile_default/ipython_config.py
#    .zshrc.min .zshrc \

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
