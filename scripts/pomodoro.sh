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
BREAK_FILE="$HOME/.pomodoro/.break"
DESC_MAX=24

raw=$(pomodoro status -f '%r|%R|%d|%t' 2>/dev/null)

# No work pomodoro: check break, otherwise idle.
if [[ -z "$raw" ]]; then
    rm -f "$DONE_MARKER"

    if [[ -f "$BREAK_FILE" ]]; then
        end_ts=$(cat "$BREAK_FILE" 2>/dev/null || echo 0)
        now=$(date +%s)
        if (( end_ts > now )); then
            remaining=$((end_ts - now))
            mm=$((remaining / 60))
            ss=$((remaining % 60))
            printf '{"text": "☕ %d:%02d · Break", "tooltip": "Break in progress", "class": "break"}\n' "$mm" "$ss"
            exit 0
        else
            # Break expired during this poll: fire one notification and clean up.
            rm -f "$BREAK_FILE"
            notify-send -a Pomodoro -u normal "Break ended" "Back to work."
        fi
    fi

    printf '{"text": "", "tooltip": "", "class": "idle"}\n'
    exit 0
fi

IFS='|' read -r remaining minutes description tags <<<"$raw"

# Truncate description for the bar (full text stays in tooltip)
desc_short="$description"
if (( ${#desc_short} > DESC_MAX )); then
    desc_short="${desc_short:0:$((DESC_MAX - 1))}…"
fi
desc_suffix=""
[[ -n "$desc_short" ]] && desc_suffix=" · $desc_short"

if [[ "$minutes" == "0" ]]; then
    # Work timer reached zero — fire one-shot notification
    if [[ ! -f "$DONE_MARKER" ]]; then
        notify-send -a Pomodoro -u critical "Pomodoro complete" "${description:-Time for a break.}"
        touch "$DONE_MARKER"
    fi
    text="🍅 done${desc_suffix}"
    class="done"
    tooltip="Done — ${description:-no description}"
else
    rm -f "$DONE_MARKER"
    text="🍅 ${remaining}${desc_suffix}"
    class="running"
    tooltip="${description:-Pomodoro} (${tags:-no tags})"
fi

# Minimal JSON escaping
text=${text//\\/\\\\}; text=${text//\"/\\\"}
tooltip=${tooltip//\\/\\\\}; tooltip=${tooltip//\"/\\\"}

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
