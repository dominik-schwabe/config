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
accountsservice
alacritty
android-file-transfer
arandr
arc-gtk-theme
discord
dunst
evince
feh
firefox
flameshot
i3-wm
i3lock
libreoffice-still
lightdm
lightdm-gtk-greeter
nm-connection-editor
nomacs
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
thunderbird
ttf-arphic-ukai
ttf-arphic-uming
ttf-baekmuk
ttf-dejavu
ttf-fira-mono
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
jmtpfs
"

installyay() {
    YAYPATH=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git $YAYPATH
    cd $YAYPATH
    makepkg -si
}

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

INSTALLSTRING=""
if [ -n "$INSTALLBASE" ]; then
    echo -e "install ${RED}base${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${BASE}"
fi

if [ -n "$INSTALLGRAPHICAL" ]; then
    echo -e "install ${GREEN}graphical${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${GRAPHIC}"
fi

if [ -n "$INSTALLLATEX" ]; then
    echo -e "install ${ORANGE}latex${RESET}"
    INSTALLSTRING="${INSTALLSTRING} ${LATEX}"
fi

[ -n "$INSTALLAUR" ] && echo -e "install ${BLUE}aur${RESET}"

INSTALLSTRING=$(echo -n $INSTALLSTRING | tr "\n" " " | sed -e "s/\s\+/ /g" -e "s/^\s\+|\s\+$//g")
AURPKG=$(echo -n $AURPKG | tr "\n" " " | sed -e "s/\s\+/ /g" -e "s/^\s\+|\s\+$//g")

if [ -z "$INSTALLSTRING" -a -z "$INSTALLAUR" ]; then
    echo -e "specify packages with -b (${RED}base${RESET}), -g (${GREEN}graphical${RESET}), -l (${ORANGE}latex${RESET}), -u (${BLUE}aur${RESET}), -a (${VIOLET}all${RESET})"
    exit 1
fi
if [ -n "$INSTALLSTRING" ]; then
    echo "$INSTALLSTRING"
    if command -v sudo &>/dev/null; then
        sudo pacman -S --needed $INSTALLSTRING || exit 1
    else
        su -c "pacman -S --needed $INSTALLSTRING" || exit 1
    fi
fi
if ! command -v yay &>/dev/null; then
    echo -e "installing ${BLUE}yay${RESET}"
    installyay || exit 1
fi
if [ -n "$INSTALLAUR" ]; then
    echo "$AURPKG"
    yay -S --needed $AURPKG || exit 1
fi
