#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"
set -euo pipefail

# Rofi-driven launcher for openpomodoro-cli + our custom break system.
# See common/pomodoro.nix and scripts/pomodoro.sh for the surrounding pieces.

POMO_DIR="$HOME/.pomodoro"
BREAK_FILE="$POMO_DIR/.break"
SETTINGS_FILE="$POMO_DIR/settings"

# ── State detection ────────────────────────────────────────────────────────
# Work pomodoro state:  running | done | absent
work_raw=$(pomodoro status -f '%r|%R|%d|%t' 2>/dev/null || true)
work_remaining=""; work_minutes=""; work_desc=""
if [[ -n "$work_raw" ]]; then
    IFS='|' read -r work_remaining work_minutes work_desc _ <<<"$work_raw"
fi

# Break state: read end timestamp from BREAK_FILE; expired files are
# garbage-collected by the waybar poller, so we just trust what's there.
break_remaining=0
if [[ -f "$BREAK_FILE" ]]; then
    end_ts=$(cat "$BREAK_FILE" 2>/dev/null || echo 0)
    now=$(date +%s)
    if (( end_ts > now )); then
        break_remaining=$((end_ts - now))
    fi
fi

# Pick the active state
#   running   work timer > 0  (highest priority)
#   done      work timer == 0
#   break     no work pomo, break in progress
#   idle      nothing
if [[ -n "$work_raw" && "$work_minutes" != "0" ]]; then
    state="running"
elif [[ -n "$work_raw" ]]; then
    state="done"
elif (( break_remaining > 0 )); then
    state="break"
else
    state="idle"
fi

# ── Header (rofi -mesg) ────────────────────────────────────────────────────
case "$state" in
    running) header="🍅 ${work_remaining} · ${work_desc:-no description}" ;;
    done)    header="🍅 done · ${work_desc:-no description}" ;;
    break)
        mm=$((break_remaining / 60))
        ss=$((break_remaining % 60))
        header=$(printf "☕ %d:%02d · Break" "$mm" "$ss")
        ;;
    idle)    header="🍅 idle" ;;
esac

# ── Items per state ────────────────────────────────────────────────────────
items=()

if [[ "$state" == "running" ]]; then
    # State A: only Cancel and Finish. Cancel first (the one you'll
    # actually use); Finish is the niche corrected-elapsed verb.
    items+=("✗ Cancel")
    items+=("✓ Finish")
else
    # State C (idle / done / break)
    # "Take a break" is hidden if we're already in one — to leave a
    # break early, the user just starts a task.
    if [[ "$state" != "break" ]]; then
        items+=("☕ Take a break")
    fi

    # Recent tasks: extract descriptions from history, dedupe keeping
    # the most recent occurrence, cap at 10.
    if [[ -f "$POMO_DIR/history" ]]; then
        mapfile -t recent < <(
            tac "$POMO_DIR/history" \
                | sed -n 's/.*description="\([^"]*\)".*/\1/p' \
                | grep -v '^$' \
                | awk '!seen[$0]++' \
                | head -n 10
        )
        for task in "${recent[@]}"; do
            items+=("⟲ $task")
        done
    fi
fi

# ── Rofi theme: top-anchored full-width bar (matches pass-menu) ────────────
THEME='
window {
    anchor: north;
    location: north;
    width: 100%;
    background-color: #1e1e2eee;
    padding: 4px 8px;
    children: [ horibox ];
}
horibox {
    orientation: horizontal;
    children: [ prompt, mesg, entry, listview ];
    background-color: transparent;
    spacing: 8px;
}
prompt {
    text-color: #89b4fa;
    background-color: transparent;
    padding: 4px 8px;
}
textbox {
    text-color: #f9e2af;
    background-color: transparent;
    padding: 4px 8px;
}
entry {
    expand: false;
    width: 16em;
    text-color: #cdd6f4;
    background-color: transparent;
    placeholder: "task...";
    placeholder-color: #6c7086;
    padding: 4px 0px;
}
listview {
    layout: horizontal;
    lines: 100;
    background-color: transparent;
    spacing: 4px;
    scrollbar: false;
}
element {
    padding: 4px 8px;
    background-color: transparent;
    text-color: #a6adc8;
    border-radius: 4px;
}
element selected.normal {
    background-color: #313244;
    text-color: #cdd6f4;
}
element-text {
    background-color: inherit;
    text-color: inherit;
}
'

# ── Run rofi ───────────────────────────────────────────────────────────────
selected=$(printf '%s\n' "${items[@]}" | rofi -dmenu \
    -no-config \
    -p "pomo" \
    -mesg "$header" \
    -location 2 \
    -matching fuzzy \
    -i \
    -theme-str "$THEME") && rc=0 || rc=$?

# Esc / cancelled → exit silently
if (( rc != 0 )); then
    exit 0
fi

# Empty selection (Enter on nothing) → also exit silently
if [[ -z "$selected" ]]; then
    exit 0
fi

# ── Dispatch ───────────────────────────────────────────────────────────────
start_break() {
    local break_min
    break_min=$(awk -F= '/^default_break_duration=/{print $2; exit}' "$SETTINGS_FILE" 2>/dev/null || true)
    break_min=${break_min:-5}
    local end_ts=$(($(date +%s) + break_min * 60))
    echo "$end_ts" > "$BREAK_FILE"
    notify-send -a Pomodoro -u normal "Break started" "${break_min}-minute break."
}

case "$state" in
    running)
        case "$selected" in
            "✗ Cancel") pomodoro cancel ;;
            "✓ Finish") pomodoro finish ;;
            *) ;;  # ignore unknown input in running state
        esac
        ;;
    done|break|idle)
        case "$selected" in
            "☕ Take a break")
                # Wipe a leftover done work pomo so the break is visible
                # in waybar. `clear` only touches current, not history.
                pomodoro clear >/dev/null 2>&1 || true
                start_break
                ;;
            *)
                # Starting a task — either a recent (⟲ prefix) or typed.
                if [[ "$selected" == "⟲ "* ]]; then
                    task="${selected#⟲ }"
                else
                    task="$selected"
                fi
                if [[ -z "$task" ]]; then
                    exit 0
                fi
                # If a break is running, cancel it (silent, by design).
                rm -f "$BREAK_FILE" 2>/dev/null || true
                pomodoro start "$task"
                ;;
        esac
        ;;
esac
