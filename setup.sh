#!/usr/bin/env bash

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

echo "binsetup"
bash bin/setup.sh $FORCE
echo
echo "configsetup"
bash userconf/setup.sh $FORCE
