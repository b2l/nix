#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

isPaused=$(dunstctl is-paused)

if ($isPaused -eq true); then
  echo '{"class": "Do not disturb", "text": "󰂛"}'
else
  echo '{"class": "Do not disturb", "text": "󰂚"}'
fi
