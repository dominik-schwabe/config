#!/usr/bin/bash

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

echo "clonesetup"
clone/setup.sh $FORCE
echo
echo "binsetup"
bin/setup.sh $FORCE
echo
echo "configsetup"
userconf/setup.sh $FORCE
