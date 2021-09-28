#!/usr/bin/env bash

FONT_FOLDER=$HOME/.local/share/fonts

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

declare -A FONT_URLS=(
  ["Fira Mono Regular Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/complete/Fira%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.otf
  ["Fira Mono Medium Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Medium/complete/Fira%20Mono%20Medium%20Nerd%20Font%20Complete%20Mono.otf
  ["Fira Mono Bold Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Bold/complete/Fira%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.otf
)

mkdir -p $FONT_FOLDER && cd $FONT_FOLDER && {
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
}
