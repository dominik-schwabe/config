#!/usr/bin/env bash

cd $(dirname $0)

BIN=$HOME/bin
LOCAL_PATH=$HOME/.local

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

extract() {
  case "$1" in
    *.tar.bz2|*.tbz2) tar xvjf "$1"    ;;
    *.tar.xz)         tar xvJf "$1"    ;;
    *.tar.gz|*.tgz)   tar xvzf "$1"    ;;
    *.tar)            tar xvf "$1"     ;;
    *.zip)            unzip "$1"       ;;
    *)                return 1
  esac
  return 0
}

download_tool() {(
  TOOL_NAME=$1
  REPO=$2
  ARCHIVE_URL=$(./tools/get_url.py $REPO) || return 1
  TEMP_FOLDER=$(mktemp -d)
  cd $TEMP_FOLDER
  curl -fsSLO "$ARCHIVE_URL" -o $TEMP_FOLDER || return 1
  ARCHIVE=$(ls)
  if extract $ARCHIVE; then
    ARCHIVE="${ARCHIVE%%.tar*}"
    ARCHIVE="${ARCHIVE%%.zip*}"
    if [[ -d $ARCHIVE ]]; then
      cd "$ARCHIVE" || return 1
    fi
  else
    mv $ARCHIVE $TOOL_NAME
  fi
  mkdir -p $LOCAL_PATH
  cp -r * "$LOCAL_PATH"
  return 0
)}

if [[ "$1" == "-r" ]]; then
  echo -n "removing nvim"
  rm -rf ~/.local/bin/nvim
  rm -rf ~/.local/lib/nvim
  rm -rf ~/.local/share/nvim/runtime
  rm -rf ~/.local/share/locale
  rm -rf ~/.local/share/man
  rm -rf ~/.local/share/icons
  rm -rf ~/.local/share/applications
  echo -e " ${GREEN}success${RESET}"
else
  mkdir -p $BIN && {
    TOOL_NAME="nvim"
    echo -n "installing $TOOL_NAME"
    if [[ ( -e "$BIN/$TOOL_NAME" || -e "$LOCAL_PATH/bin/$TOOL_NAME" ) && "$1" != "-f" ]]; then
        echo -e " ${BLUE}exists${RESET}"
    else
      if download_tool "$TOOL_NAME" "neovim/neovim" &>/dev/null; then
        echo -e " ${GREEN}success${RESET}"
      else
        echo -e " ${RED}failure${RESET}"
      fi
    fi
  }
fi
