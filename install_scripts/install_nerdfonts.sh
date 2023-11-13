#!/usr/bin/env bash

FONT_FOLDER=$HOME/.local/share/fonts

GREEN="\e[1;32m"
BLUE="\e[1;34m"
RED="\e[1;31m"
RESET="\e[0m"

declare -A FONT_URLS=(
  ["FiraCodeNerdFont-Regular.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
  ["FiraCodeNerdFont-Medium.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/FiraCodeNerdFont-Medium.ttf
  ["FiraCodeNerdFont-SemiBold.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/SemiBold/FiraCodeNerdFont-SemiBold.ttf
  ["FiraCodeNerdFont-Bold.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/FiraCodeNerdFont-Bold.ttf
  ["FiraCodeNerdFont-Light.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/FiraCodeNerdFont-Light.ttf
  ["FiraCodeNerdFont-Retina.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/FiraCodeNerdFont-Retina.ttf
)

if mkdir -p $FONT_FOLDER && cd $FONT_FOLDER; then
  for FONT_NAME in "${!FONT_URLS[@]}"; do
    echo -n "installing $FONT_NAME"
    if [[ -e "./$FONT_NAME" && "$1" != "-f" ]]; then
      echo -e " ${BLUE}exists${RESET}"
    else
      if curl -sfLo "$FONT_NAME" "${FONT_URLS[$FONT_NAME]}"; then
        echo -e " ${GREEN}success${RESET}"
      else
        echo -e " ${RED}failure${RESET}"
      fi
    fi
  done
fi
