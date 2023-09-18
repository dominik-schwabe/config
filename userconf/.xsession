#!/usr/bin/env bash

xset r rate 200 33
setxkbmap de nodeadkeys
setxkbmap -option 'ctrl:nocaps'

TRACKPOINT_VENDOR=$(xinput | sed -n "/TPPS\/2 .* TrackPoint/p" | sed "s/.*TPPS\/2 \(.*\) TrackPoint.*/\1/")
if [[ -n $TRACKPOINT_VENDOR ]]; then
  if [[ $TRACKPOINT_VENDOR == "IBM" ]]; then
    xinput set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Speed" -0.4
  elif [[ $TRACKPOINT_VENDOR == "Elan" ]]; then
    xinput set-prop "TPPS/2 Elan TrackPoint" "libinput Accel Speed" 0.6
    xinput set-prop "TPPS/2 Elan TrackPoint" "libinput Scrolling Pixel Distance" 10
  else
    echo "Unknown TrackPoint Vendor: $TRACKPOINT_VENDOR"
  fi
fi

killall --quiet xbindkeys
xbindkeys

[[ -f $HOME/.xmodmaprc ]] && xmodmap $HOME/.xmodmaprc

TOUCHPAD_DEVICE=$(xinput | grep -i synaptics | sed -n 's/.*id=\([0-9]\+\).*/\1/p')
if [[ -n "$TOUCHPAD_DEVICE" ]]; then
  synclient VertScrollDelta=-60
  synclient TapButton1=1
  synclient TapButton2=3
  synclient TapButton3=2
  synclient AreaLeftEdge=350
  synclient AreaRightEdge=1750
  synclient ClickPad=0
  synclient MinSpeed=1
  synclient FingerLow=25
  synclient FingerHigh=30
  synclient MaxSpeed=1.75
  synclient AccelFactor=0.1
  synclient ClickTime=100
  synclient MaxTapTime=80
  synclient MaxTapMove=20
  synclient SingleTapTimeout=150
  synclient CoastingSpeed=10
  synclient CoastingFriction=20
  synclient HorizHysteresis=10
  synclient VertHysteresis=10
  xinput --set-prop "$TOUCHPAD_DEVICE" "Synaptics Finger" 35 45 250
fi

[[ -f $HOME/.xsession_extra ]] && . $HOME/.xsession_extra
