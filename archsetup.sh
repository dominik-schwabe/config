#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
VIOLET="\e[35m"
RESET="\e[0m"

BASE="\
acpid \
alsa \
alsa-tools \
alsa-utils \
arch-install-scripts \
autopep8 \
avahi \
awesome-terminal-fonts \
base \
base-devel \
bash-completion \
bluez \
bluez-utils \
cmake \
cmus \
cronie \
ctags \
cups \
curl \
dnsutils \
docker \
docker-compose \
dosfstools \
efibootmgr \
eslint \
flake8 \
fzf \
gcc-fortran \
git \
grub \
gutenprint \
gvim \
jre-openjdk \
linux \
neovim \
networkmanager \
nodejs \
npm \
ntp \
openssh \
pacman-contrib \
pamixer \
pulseaudio-alsa \
pulseaudio-bluetooth \
pulsemixer \
python \
python-pip \
python2 \
python2-pip \
ranger \
rsync \
sshfs \
sudo \
termdown \
tmux \
tor \
unzip \
usbutils \
vim-spell-de \
vim-spell-en \
wget \
zip \
zsh \
"

GRAPHIC="\
accountsservice \
android-file-transfer \
android-file-transfer \
arandr \
arc-gtk-theme \
dunst \
evince \
feh \
firefox \
flameshot \
gimp \
gvfs \
gvfs-mtp \
i3-wm \
i3lock \
libreoffice-still \
lightdm \
lightdm-gtk-greeter \
mtpfs \
nm-connection-editor \
nomacs \
noto-fonts \
pavucontrol \
perl-file-mimeinfo \
picom \
powerline-fonts \
redshift \
rofi \
scrot \
system-config-printer \
telegram-desktop \
alacritty \
texlive-lang \
texlive-most \
thunar \
thunar-archive-plugin \
thunar-media-tags-plugin \
thunar-volman \
ttf-arphic-ukai \
ttf-arphic-uming \
ttf-baekmuk \
ttf-dejavu \
ttf-sazanami \
xbindkeys \
xclip \
xdotool \
xorg \
xorg-apps \
xorg-drivers \
xorg-fonts \
xorg-xinit \
zathura \
zathura-pdf-poppler \
"

AURPKG="\
cht.sh \
i3pystatus-git \
jmtpfs \
lightdm-mini-greeter \
neovim-remote \
nodejs-neovim \
python-basiciw \
ruby-neovim \
tmuxinator \
tor-browser \
ttf-devicons \
"

installyay() {
    YAYPATH=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git $YAYPATH
    cd $YAYPATH
    makepkg -si
}

INSTALLBASE=0
INSTALLGRAPHICAL=0
INSTALLAUR=0

while getopts "abgpu" o &> /dev/null
do
    case $o in
        "a")
            INSTALLBASE=1
            INSTALLGRAPHICAL=1
            INSTALLAUR=1
            ;;
        "b")
            INSTALLBASE=1
            ;;
        "g")
            INSTALLGRAPHICAL=1
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

if [ $INSTALLAUR -eq 1 ]
then
    echo -e "install ${BLUE}aur${RESET}"
fi

if [ $PACMAN -eq 0 -a $INSTALLAUR -eq 0 ]
then
    echo -e "specify packages with -b (${RED}base${RESET}), -g (${GREEN}graphical${RESET}), -p (${ORANGE}python-packages${RESET}), -u (${BLUE}aur${RESET}), -a (${VIOLET}all${RESET})"
else
    echo
    echo $INSTALLSTRING
    echo
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
