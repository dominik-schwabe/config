#!/bin/bash

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
bash clone/setup.sh $FORCE
echo
echo "binsetup"
bash bin/setup.sh $FORCE
echo
echo "configsetup"
bash userconf/setup.sh $FORCE
