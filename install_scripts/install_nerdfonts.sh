#!/usr/bin/env bash

FONT_FOLDER=$HOME/.local/share/fonts

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

declare -A FONT_URLS=(
  ["Fira Code Regular Nerd Font Complete.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
  ["Fira Code Medium Nerd Font Complete.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira%20Code%20Medium%20Nerd%20Font%20Complete.ttf
  ["Fira Code Bold Nerd Font Complete.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira%20Code%20Bold%20Nerd%20Font%20Complete.ttf
  # ["Fura Mono Regular Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/complete/Fura%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.otf
  # ["Fura Mono Medium Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Medium/complete/Fura%20Mono%20Medium%20Nerd%20Font%20Complete%20Mono.otf
  # ["Fura Mono Bold Nerd Font Complete Mono.otf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Bold/complete/Fura%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.otf
  # ["Sauce Code Pro Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Sauce Code Pro Medium Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Medium/complete/Sauce%20Code%20Pro%20Medium%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Sauce Code Pro Bold Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Bold/complete/Sauce%20Code%20Pro%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Sauce Code Pro Italic Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Italic/complete/Sauce%20Code%20Pro%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Hack Regular Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Hack Italic Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Hack Bold Italic Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Hack Bold Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Fira Code Bold Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira%20Code%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Fira Code Medium Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/complete/Fira%20Code%20Medium%20Nerd%20Font%20Complete%20Mono.ttf
  # ["Fira Code Regular Nerd Font Complete Mono.ttf"]=https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
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
