#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m"
RESET="\e[0m"

BASE="\
alsa \
alsa-tools \
alsa-utils \
arch-install-scripts \
avahi \
base \
base-devel \
bash-completion \
cmake \
cmus \
cronie \
curl \
efibootmgr \
git \
grub \
gvim \
htop \
ipython \
linux
maven \
neovim
networkmanager \
nodejs \
npm \
ntp \
openjdk \
pacman-contrib \
pulseaudio-alsa \
pyenv \
python \
python-jedi \
python-language-server \
python-pip \
python-pipenv \
python-pynvim \
python2 \
python2-pip \
r \
ranger \
rsync \
screen \
sudo \
tmux \
tor \
unzip \
vim-spell-de \
vim-spell-en \
zip \
zsh \
"

PYTHON="\
python-dbus \
python-flask \
python-iwlib \
python-matplotlib \
python-nltk \
python-numpy \
python-pandas \
python-pyalsa \
python-pygments \
python-pylint \
python-pytz \
python-rope \
python-scipy \
"

GRAPHIC="\
accountsservice \
android-file-transfer \
arandr \
arc-gtk-theme \
bluez \
bluez-utils \
dunst \
evince \
firefox \
gimp \
gtk-redshift \
i3 \
libreoffice \
lightdm \
lightdm-gtk-greeter \
nm-connection-editor \
noto-fonts \
pavucontrol \
redshift \
scrot \
system-config-printer \
termite \
texlive-lang \
texlive-most \
thunar \
tor-browser \
ttf-arphic-ukai \
ttf-arphic-uming \
ttf-baekmuk \
ttf-sazanami \
vlc \
xorg \
xorg-apps \
xorg-drivers \
xorg-fonts \
xorg-init \
zathura \
zathura-pdf-poppler \
"

AURPKG="\
lightdm-mini-greeter \
tor-browser \
"

installyay() {
    YAYPATH=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git $YAYPATH
    cd $YAYPATH
    makepkg -si
}

INSTALLBASE=0
INSTALLGRAPHICAL=0
INSTALLPYTHONPKG=0
INSTALLAUR=0

while getopts "abgpu" o &> /dev/null
do
    case $o in
        "a")
            INSTALLBASE=1
            INSTALLGRAPHICAL=1
            INSTALLPYTHONPKG=1
            INSTALLAUR=1
            ;;
        "b")
            INSTALLBASE=1
            ;;
        "g")
            INSTALLGRAPHICAL=1
            ;;
        "p")
            INSTALLPYTHONPKG=1
            ;;
        "u")
            INSTALLAUR=1
            ;;
    esac
done

PACMAN=0
AUR=0

INSTALLSTRING=""
if [ $INSTALLBASE -eq 1 ]
then
    echo -e "install ${RED}base${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${BASE}
    PACMAN=1
fi

if [ $INSTALLGRAPHICAL -eq 1 ]
then
    echo -e "install ${GREEN}graphical${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${GRAPHIC}
    PACMAN=1
fi

if [ $INSTALLPYTHONPKG -eq 1 ]
then
    echo -e "install ${ORANGE}python-packages${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${PYTHON}
    PACMAN=1
fi

if [ $INSTALLAUR -eq 1 ]
then
    echo -e "install ${BLUE}aur${RESET}"
fi
echo
echo $INSTALLSTRING
echo

if [ $PACMAN -eq 0 -a $INSTALLAUR -eq 0 ]
then
    echo -e "specify packages with -b (${RED}base${RESET}), -g (${GREEN}graphical${RESET}), -p (${ORANGE}python-packages${RESET}), -u (${BLUE}aur${RESET}), -a (${VIOLET}all${RESET})"
else
    if [ $PACMAN -eq 1 ]
    then
        su -c "pacman -S $INSTALLSTRING"
    fi

    if [ $INSTALLBASE -eq 1 ]
    then
        echo -e "installing ${BLUE}yay${RESET}"
        installyay
    fi

    if [ $INSTALLAUR -eq 1 ]
    then
        yay -S $AURPKG
    fi
fi
