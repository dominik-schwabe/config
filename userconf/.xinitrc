xset r rate 200 33
setxkbmap de nodeadkeys
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
exec i3

# vi: ft=sh
