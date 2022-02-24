xset r rate 200 33
setxkbmap de nodeadkeys
setxkbmap -option 'ctrl:nocaps'

xinput set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Speed" -0.4
killall xbindkeys; xbindkeys

if [ -f $HOME/.xmodmaprc ]; then
  /usr/bin/xmodmap $HOME/.xmodmaprc
fi

synclient VertScrollDelta=-110
synclient TapButton1=1
synclient TapButton2=3
synclient TapButton3=2


# vi: ft=sh
