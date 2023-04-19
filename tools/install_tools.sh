#!/usr/bin/env bash

cd $(dirname $0)

BIN=$HOME/bin
LOCAL_PATH=$HOME/.local

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

declare -A TOOLS=(
  ["rg"]="BurntSushi/ripgrep"
  ["fzf"]="junegunn/fzf"
  ["fd"]="sharkdp/fd"
  ["jq"]="stedolan/jq"
  ["zoxide"]="ajeetdsouza/zoxide"
)

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
  ARCHIVE_URL=$(./get_url.py $REPO) || return 1
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
  chmod 755 "$TOOL_NAME" || return 1
  mv $TOOL_NAME $BIN || return 1
  rm -rf $TEMP_FOLDER || return 1
  return 0
)}

mkdir -p $BIN && {
  for TOOL_NAME in ${!TOOLS[@]}; do
      echo -n "installing $TOOL_NAME"
      if [[ ( -e "$BIN/$TOOL_NAME" || -e "$LOCAL_PATH/bin/$TOOL_NAME" ) && "$1" != "-f" ]]; then
          echo -e " ${BLUE}exists${RESET}"
      else
        if download_tool "$TOOL_NAME" "${TOOLS[$TOOL_NAME]}" &>/dev/null; then
          echo -e " ${GREEN}success${RESET}"
        else
          echo -e " ${RED}failure${RESET}"
        fi
      fi
  done
}
