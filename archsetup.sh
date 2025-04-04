#!/usr/bin/env bash

RED="\e[1;31m"
GREEN="\e[1;32m"
ORANGE="\e[1;33m"
BLUE="\e[1;34m"
VIOLET="\e[1;35m"
RESET="\e[0m"

grep -q vmx /proc/cpuinfo && UCODE="intel-ucode"
grep -q svm /proc/cpuinfo && UCODE="amd-ucode"

BASE="
$UCODE
glow
man-pages
man-db
alsa-tools
alsa-utils
arch-install-scripts
arp-scan
avahi
base
base-devel
bash-completion
clang
cmake
cmus
curl
dnsutils
docker
docker-buildx
docker-compose
dosfstools
efibootmgr
gcc-fortran
git
git-lfs
os-prober
refind
gvfs
gvfs-mtp
gvim
inetutils
jq
keychain
linux-firmware
linux
linux-headers
lua
luajit
luarocks
mtpfs
neovim
net-tools
networkmanager
openresolv
openssh
p7zip
pacman-contrib
python
python-pynvim
reflector
rsync
sshfs
sudo
terminus-font
tmux
unzip
usbutils
wget
zip
zsh
"

GRAPHIC="
ly
dunst
qtile
python-dbus-fast
python-psutil
python-keyring
python-pywayland
python-pywlroots
python-setproctitle
python-xdg
python-xkbcommon
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
xdg-desktop-portal
xdg-desktop-portal-gtk
tcl
tk
bluez
bluez-utils
cups
gutenprint
pamixer
pipewire
pipewire-alsa
pipewire-jack
pipewire-pulse
pulsemixer
easyeffects
helvum
wireplumber
i3lock
brightnessctl
accountsservice
wezterm
android-file-transfer
arandr
arc-gtk-theme
autorandr
awesome
discord
evince
feh
firefox
flameshot
libreoffice-still
mpv
nm-connection-editor
pavucontrol
perl-file-mimeinfo
picom
playerctl
redshift
rofi
scrot
spotify-launcher
nsxiv
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
ttf-firacode-nerd
ttf-sazanami
tumbler
udiskie
wireless_tools
xbindkeys
xclip
xsel
xcolor
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
libxcrypt-compat
perl-file-homedir
perl-yaml-tiny
perl-unicode-linebreak
inkscape
biber
texlive-lang
texlive
"

AURPKG="
birdtray
brave-bin
jmtpfs
lain-git
lua53-inspect
unclutter-xfixes-git
"

installparu() {
  PARU_PATH=$(mktemp -d)
  git clone https://aur.archlinux.org/paru-bin.git $PARU_PATH
  cd $PARU_PATH
  makepkg -si
}

while getopts "abglu" o &>/dev/null; do
  case $o in
    "a")
      INSTALLBASE=1
      INSTALLGRAPHICAL=1
      INSTALLLATEX=1
      INSTALLAUR=1
      ;;
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
if ! command -v paru &>/dev/null; then
  echo -e "installing ${BLUE}paru${RESET}"
  installparu || exit 1
fi
if [ -n "$INSTALLAUR" ]; then
  echo "$AURPKG"
  paru -S --needed $AURPKG || exit 1
fi
