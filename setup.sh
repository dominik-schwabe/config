#!/bin/bash

CURRPATH="$(pwd)/$(dirname $0)"

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zshplugins/zsh-syntax-highlighting.git

ln -s ${CURRPATH}/.vimrc ~/.vimrc $@
ln -s ${CURRPATH}/.vimrc ~/.nvimrc $@
ln -s ${CURRPATH}/.bashrc ~/.bashrc $@
ln -s ${CURRPATH}/.zshrc ~/.zshrc $@
ln -s ${CURRPATH}/.envrc ~/.envrc $@
ln -s ${CURRPATH}/.toprc ~/.toprc $@
ln -s ${CURRPATH}/.inputrc ~/.inputrc $@
mkdir ~/.config/ranger -p
ln -s ${CURRPATH}/.rc.conf ~/.config/ranger/rc.conf $@
mkdir ~/.config/termite -p
ln -s ${CURRPATH}/.termite.conf ~/.config/termite/config $@
ln -s ${CURRPATH}/.aliasrc ~/.aliasrc $@
mkdir ~/.config/i3 -p
ln -s ${CURRPATH}/.i3config ~/.config/i3/config $@
ln -s ${CURRPATH}/.i3pystatus.conf ~/.config/i3/i3pystatus.conf $@
mkdir ~/.config/nvim -p
ln -s ${CURRPATH}/.init.vim ~/.config/nvim/init.vim $@
ln -s ${CURRPATH}/.Xdefaults ~/.Xdefaults $@
ln -s ${CURRPATH}/.xsession ~/.xsession $@
ln -s ${CURRPATH}/.xsession ~/.xsessionrc $@
ln -s ${CURRPATH}/.xinitrc ~/.xinitrc $@
ln -s ${CURRPATH}/.bg.jpg ~/.bg.jpg $@
