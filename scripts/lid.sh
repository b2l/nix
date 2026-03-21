#!/usr/bin/env zsh

if [[ $(hyprctl monitors | grep -E -i "Monitor (HDMI|DP)") ]]; then
  if [[ $1 == "open" ]]; then
    hyprctl keyword monitor "eDP-1,1920x1080,2560x0,1"
  else
    hyprctl keyword monitor "eDP-1,disable"
  fi
else
  hyprctl keyword monitor "eDP-1,preferred,preferred,1"
fi
