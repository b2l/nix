#!/bin/bash

# Start work apps on specific workspaces
# firefox -> 1, foot -> 2, slack -> 3, thunderbird -> 4
# spotify -> 8, signal -> 9, chrome -> 10

hyprctl dispatch exec "[workspace 1 silent]" flatpak run org.mozilla.firefox
hyprctl dispatch exec "[workspace 2 silent]" foot
hyprctl dispatch exec "[workspace 3 silent]" slack
hyprctl dispatch exec "[workspace 4 silent]" flatpak run org.mozilla.Thunderbird
hyprctl dispatch exec "[workspace 8 silent]" flatpak run com.spotify.Client
hyprctl dispatch exec "[workspace 9 silent]" flatpak run org.signal.Signal
hyprctl dispatch exec "[workspace 10 silent]" flatpak run com.google.Chrome
