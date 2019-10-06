#!/usr/bin/env sh

#echo "KEMAP=de" > /etc/vconsole.conf
#echo "LANG=de_DE.UTF-8" > /etc/locale.conf
#echo "dominiksArch" > /etc/hostname
#echo "127.0.0.1	localhost
#::1		localhost" > /etc/hosts
#ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

main() {
    CURRPATH="$(pwd)/$(dirname $0)"

    GREEN="\e[32m"
    RED="\e[31m"
    RESET="\e[0m"

    cpconfig() {
        DESTPATH=$1
        SRCPATH=${CURRPATH}/rootconf/$(basename $DESTPATH)
        DESTDIR=$(dirname $DESTPATH)
        F=$2
        mkdir -p $DESTDIR
        cp $SRCPATH $DESTPATH &> /dev/null
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}success${RESET} copying $DESTPATH"
        else
            echo -e "${RED}failure${RESET} copying $DESTPATH"
        fi
    }

    set \
        /etc/lightdm/lightdm.conf \
        /etc/lightdm/lightdm-gtk-greeter.conf \
        /etc/lightdm/lightdm-mini-greeter.conf \
        /usr/share/backgrounds/stars.png


    while [ $# -gt 0 ]
    do
        ARG=$1
        cpconfig $ARG
        shift &> /dev/null
    done
}

FUNC=$(declare -f main)
su -c "$FUNC; main"
