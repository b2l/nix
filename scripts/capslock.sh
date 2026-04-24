#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

capslock=$(cat /sys/class/leds/input*::capslock/brightness | head -c 1)

if [[ "${capslock}" == "1" ]]; then
  echo '{"class": "locked", "text": ""}'
else
  echo '{"class": "unlocked", "text": ""}'
fi
