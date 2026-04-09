#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

# Waybar custom module for openpomodoro-cli.
# Polls status, displays time remaining, and fires a one-shot
# notification when a work pomodoro reaches zero — the upstream tool
# has no hook for that transition (see common/pomodoro.nix).
#
# Format string fields:  %r = mm:ss remaining,  %R = minutes remaining
# (rounded; "0" when done),  %d = description,  %t = tags.
# When no pomodoro is active, `pomodoro status` outputs an empty string.

DONE_MARKER="$HOME/.pomodoro/.done-notified"

raw=$(pomodoro status -f '%r|%R|%d|%t' 2>/dev/null)

# Idle: no current pomodoro
if [[ -z "$raw" ]]; then
    rm -f "$DONE_MARKER"
    printf '{"text": "", "tooltip": "", "class": "idle"}\n'
    exit 0
fi

IFS='|' read -r remaining minutes description tags <<<"$raw"

if [[ "$minutes" == "0" ]]; then
    # Work timer reached zero — fire one-shot notification
    if [[ ! -f "$DONE_MARKER" ]]; then
        notify-send -a Pomodoro -u critical "Pomodoro complete" "${description:-Time for a break.}"
        touch "$DONE_MARKER"
    fi
    text="🍅 done"
    class="done"
    tooltip="Done — ${description:-no description}"
else
    rm -f "$DONE_MARKER"
    text="🍅 ${remaining}"
    class="running"
    tooltip="${description:-Pomodoro} (${tags:-no tags})"
fi

# Minimal JSON escaping
text=${text//\\/\\\\}; text=${text//\"/\\\"}
tooltip=${tooltip//\\/\\\\}; tooltip=${tooltip//\"/\\\"}

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
