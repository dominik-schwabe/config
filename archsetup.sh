#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m"
RESET="\e[0m"

BASE="
alsa
alsa-tools
alsa-utils
arch-install-scripts
arp-scan
avahi
base
base-devel
bash-completion
bluez
bluez-utils
clang
cmake
cmus
cups
curl
dnsutils
docker
docker-compose
dosfstools
efibootmgr
gcc-fortran
git
gnome-keyring
grub
gutenprint
gvfs
gvfs-mtp
gvim
inetutils
jq
linux-firmware
linux-zen
mtpfs
neovim
net-tools
networkmanager
openresolv
openssh
pacman-contrib
pamixer
pulseaudio-alsa
pulseaudio-bluetooth
pulsemixer
python
python-pip
rsync
sshfs
sudo
tcl
tk
tmux
unzip
usbutils
wget
zip
zsh
"

GRAPHIC="
thunderbird
firefox
accountsservice
alacritty
android-file-transfer
arandr
arc-gtk-theme
discord
dunst
evince
feh
flameshot
i3-wm
i3lock
libreoffice-still
lightdm
lightdm-gtk-greeter
nm-connection-editor
nomacs
ttf-fira-mono
pavucontrol
perl-file-mimeinfo
picom
playerctl
redshift
rofi
scrot
sxiv
system-config-printer
telegram-desktop
thunar
thunar-archive-plugin
thunar-media-tags-plugin
thunar-volman
ttf-arphic-ukai
ttf-arphic-uming
ttf-baekmuk
ttf-dejavu
ttf-sazanami
tumbler
wireless_tools
xbindkeys
xclip
xdotool
xorg
xorg-apps
xorg-drivers
xorg-fonts
xorg-xinit
zathura
zathura-pdf-poppler
"

LATEX="
texlive-lang
texlive-most
"

AURPKG="
birdtray
cht.sh
jmtpfs
"

installyay() {
    YAYPATH=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git $YAYPATH
    cd $YAYPATH
    makepkg -si
}

INSTALLBASE=0
INSTALLGRAPHICAL=0
INSTALLLATEX=0
INSTALLAUR=0

while getopts "abglu" o &> /dev/null
do
    case $o in
        "a") INSTALLBASE=1
             INSTALLGRAPHICAL=1
             INSTALLLATEX=1
             INSTALLAUR=1 ;;
        "b") INSTALLBASE=1 ;;
        "g") INSTALLGRAPHICAL=1 ;;
        "l") INSTALLLATEX=1 ;;
        "u") INSTALLAUR=1 ;;
    esac
done

PACMAN=0
AUR=0

INSTALLSTRING=""
if [ $INSTALLBASE -eq 1 ]
then
    echo -e "install ${RED}base${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${BASE}"
    PACMAN=1
fi

if [ $INSTALLGRAPHICAL -eq 1 ]
then
    echo -e "install ${GREEN}graphical${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${GRAPHIC}"
    PACMAN=1
fi

if [ $INSTALLLATEX -eq 1 ]
then
    echo -e "install ${ORANGE}latex${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${LATEX}"
    PACMAN=1
fi

if [ $INSTALLAUR -eq 1 ]
then
    echo -e "install ${BLUE}aur${RESET}"
fi

INSTALLSTRING=$((tr "\n" " " | sed -e "s/\s\+/ /g" -e "s/^\s\+|\s\+$//g") <<< $INSTALLSTRING)

if [ $PACMAN -eq 0 -a $INSTALLAUR -eq 0 ]
then
    echo -e "specify packages with -b (${RED}base${RESET}), -g (${GREEN}graphical${RESET}), -l (${ORANGE}latex${RESET}), -u (${BLUE}aur${RESET}), -a (${VIOLET}all${RESET})"
else
    if [ $PACMAN -eq 1 ]
    then
        echo
        echo $INSTALLSTRING
        echo
        su -c "pacman -S --needed $INSTALLSTRING" || exit 1
    fi

    if [ $INSTALLBASE -eq 1 ]
    then
        echo -e "installing ${BLUE}yay${RESET}"
        installyay
    fi

    [ $INSTALLAUR -eq 1 ] && yay -S --needed $AURPKG
fi
