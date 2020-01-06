#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m"
RESET="\e[0m"

BASE="\
ctags \
sshfs \
dosfstools \
python-rope \
pulsemixer \
pamixer \
openssh \
pacman-contrib \
ack \
python-pylint \
autopep8 \
flake8 \
arch-install-scripts \
tmux \
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
wget \
curl \
efibootmgr \
git \
grub \
gvim \
htop \
ipython \
linux \
nodejs \
yarn \
maven \
neovim
python-neovim \
python2-neovim \
networkmanager \
ntp \
openjdk \
pacman-contrib \
pulseaudio-alsa \
python \
python-jedi \
python-pip \
python-pipenv \
python2 \
python2-pip \
r \
ranger \
rsync \
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
python-pipenv \
python-iwlib \
python-pyalsa \
python-pygments \
python-pytz \
"

GRAPHIC="\
xdotool \
flameshot \
arc-gtk-theme \
accountsservice \
android-file-transfer \
arandr \
bluez \
bluez-utils \
dunst \
evince \
firefox \
gimp \
i3 \
libreoffice \
lightdm \
lightdm-gtk-greeter \
nm-connection-editor \
noto-fonts \
pavucontrol \
redshift \
feh \
scrot \
system-config-printer \
termite \
texlive-lang \
texlive-most \
gvfs \
thunar \
thunar-volman \
thunar-media-tags-plugin \
thunar-archive-plugin \
ttf-dejavu \
ttf-arphic-ukai \
ttf-arphic-uming \
ttf-baekmuk \
ttf-sazanami \
rofi \
vlc \
xclip \
xorg \
xorg-apps \
xorg-drivers \
xorg-fonts \
xorg-xinit \
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
