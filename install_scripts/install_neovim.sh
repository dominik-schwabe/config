#!/usr/bin/env bash

CLONE_FOLDER=/tmp/neovim_git_clone
THIS_PATH=$(pwd)

if [[ ! -d $CLONE_FOLDER ]]
then
    git clone https://github.com/neovim/neovim $CLONE_FOLDER
fi

cd $CLONE_FOLDER
git checkout stable

if make CMAKE_INSTALL_PREFIX=$HOME/local/ CMAKE_BUILD_TYPE=Release install;
then
    cd $THIS_PATH
    rm $CLONE_FOLDER -rf
fi

