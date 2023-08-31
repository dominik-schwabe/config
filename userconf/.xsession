#!/usr/bin/env bash

xset r rate 200 33
setxkbmap de nodeadkeys
setxkbmap -option 'ctrl:nocaps'

TRACKPOINT_VENDOR=$(xinput | sed -n "/TPPS\/2 .* TrackPoint/p" | sed "s/.*TPPS\/2 \(.*\) TrackPoint.*/\1/")
if [[ -n $TRACKPOINT_VENDOR ]]; then
  if [[ $TRACKPOINT_VENDOR == "IBM" ]]; then
    xinput set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Speed" -0.4
  elif [[ $TRACKPOINT_VENDOR == "Elan" ]]; then
    xinput set-prop "TPPS/2 Elan TrackPoint" "libinput Accel Speed" +1
  else
    echo "Unknown TrackPoint Vendor: $TRACKPOINT_VENDOR"
  fi
fi
killall --quiet xbindkeys
xbindkeys

[[ -f $HOME/.xmodmaprc ]] && xmodmap $HOME/.xmodmaprc

synclient VertScrollDelta=-110
synclient TapButton1=1
synclient TapButton2=3
synclient TapButton3=2

# vi: ft=sh
