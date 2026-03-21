#!/bin/bash

isPaused=$(dunstctl is-paused)

if ($isPaused -eq true); then
  echo '{"class": "Do not disturb", "text": ""}'
else
  echo '{"class": "Do not disturb", "text": ""}'
fi
