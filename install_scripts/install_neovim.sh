#!/usr/bin/env bash

CLONE_FOLDER=$HOME/.neovim_git_clone

[ -d $CLONE_FOLDER ] || git clone https://github.com/neovim/neovim $CLONE_FOLDER

cd $CLONE_FOLDER
git checkout stable

if make CMAKE_INSTALL_PREFIX=$HOME/local/ CMAKE_BUILD_TYPE=Release install;
then
    cd ~
    rm $CLONE_FOLDER -rf
fi

