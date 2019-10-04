#!/bin/env sh

GREEN="\e[32m"
RED="\e[31m"
ORANGE="\e[33m"
VIOLET="\e[35m"
RESET="\e[0m"

BASE="\
base \
base-devel \
bash-completion \
python \
python-pip \
python2 \
python2-pip \
python-pipenv \
pyenv \
ipython \
sudo \
git \
gvim \
neovim
python-pynvim \
python-language-server \
python-jedi \
vim-spell-de \
vim-spell-en \
zsh \
zsh-completion \
networkmanager \
cmake \
screen \
tmux \
zip \
unzip \
ranger \
rsync \
r \
tor \
grub \
openjdk \
maven \
cmus \
acpid \
pulseaudio-alsa \
alsa \
alsa-tools \
alsa-utils \
arch-install-scripts \
efibootmgr \
htop \
avahi \
ntp \
cronie \
"

PYTHON="\
python-cairocffi \
python-dbus \
python-flake8-debugger \
python-flask \
python-gensim \
python-gobject \
python-iwlib \
python-markupsafe \
python-matplotlib \
python-nltk \
python-numpy \
python-opengl \
python-pandas \
python-pip \
python-pipenv \
python-pmw \
python-pyalsa \
python-pygame \
python-pygments \
python-pylint \
python-pytz \
python-rope \
python-scipy \
"

GRAPHIC="\
xorg \
xorg-init \
xorg-apps \
xorg-drivers \
xorg-fonts \
lightdm \
lightdm-gtk-greeter \
accountsservice \
i3 \
pavucontrol \
nm-connection-editor \
arandr \
bluez \
bluez-utils \
arc-gtk-theme \
android-file-transfer \
dunst \
zathura \
zathura-pdf-poppler \
evince \
libreoffice \
redshift \
noto-fonts \
scrot \
gimp \
vlc \
gtk-redshift \
termite \
firefox \
thunar \
tor-browser \
texlive-most \
texlive-lang \
ttf-arphic-ukai \
ttf-arphic-uming \
ttf-baekmuk \
ttf-sazanami \
"

INSTALLBASE=0
INSTALLGRAPHICAL=0
INSTALLPYTHONPKG=0

while getopts "abgp" o &> /dev/null
do
    case $o in
        "a")
            INSTALLBASE=1
            INSTALLGRAPHICAL=1
            INSTALLPYTHONPKG=1
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
    esac
done

NUMPKGS=0

INSTALLSTRING=""
if [ $INSTALLBASE -eq 1 ]
then
    echo -e "install ${RED}base${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${BASE}
    NUMPKGS=$(expr $NUMPKGS + 1)
fi

if [ $INSTALLGRAPHICAL -eq 1 ]
then
    echo -e "install ${GREEN}graphical${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${GRAPHIC}
    NUMPKGS=$(expr $NUMPKGS + 1)
fi

if [ $INSTALLPYTHONPKG -eq 1 ]
then
    echo -e "install ${ORANGE}python-packages${RESET}"
    INSTALLSTRING=${INSTALLSTRING}${PYTHON}
    NUMPKGS=$(expr $NUMPKGS + 1)
fi

if [ $NUMPKGS -eq 0 ]
then
    echo -e "specify packages with -b (${RED}base${RESET}), -g (${GREEN}graphical${RESET}), -p (${ORANGE}python-packages${RESET}), -a (${VIOLET}all${RESET})"
else
    su -c "pacman -S $INSTALLSTRING"
fi
