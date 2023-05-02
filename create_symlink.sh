#!/usr/bin/env bash

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

SYMLINK="-sr"

while [ $# != "0" ]; do
  while getopts "fh" o; do
    [ $o == "f" ] && FORCE="-f"
    [ $o == "h" ] && SYMLINK=""
  done
  while [ $OPTIND -gt 1 ]; do
    shift
    ((OPTIND--))
  done
  if [ $# != "0" ]; then
    if [ -z "$SRCPATH" ]; then
      SRCPATH=$1
    elif [ -z "$DESTPATH" ]; then
      DESTPATH=$1
    fi
    shift
  fi
done

if ! [ -e "$SRCPATH" ]; then
  echo -e "${RED}failure $SRCPATH does not exist${RESET}"
  exit 1
fi
if [ -e "$DESTPATH" -o -L "$DESTPATH" ]; then
  if [ "$SRCPATH" -ef "$DESTPATH" ]; then
    echo -e "${BLUE}exists${RESET} link $DESTPATH"
    exit 0
  elif [ -n "$FORCE" ]; then
    rm -rf "$DESTPATH"
  else
    echo -e "${RED}failure${RESET} path exists $DESTPATH"
    exit 1
  fi
fi
if ! mkdir -p $(dirname "$DESTPATH"); then
  echo -e "${RED}failure${RESET} creating directory $DESTPATH"
  exit 1
else
  ln $SYMLINK "$SRCPATH" "$DESTPATH" &>/dev/null
  echo -e "${GREEN}success${RESET} creating link $DESTPATH"
  exit 0
fi
echo -e "${RED}failure${RESET} creating link $DESTPATH"
exit 1
