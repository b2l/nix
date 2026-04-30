#!/usr/bin/env bash
PIDFILE="/tmp/dictate.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    echo '{"text": "󰍬", "class": "recording", "tooltip": "Dictation active"}'
else
    echo '{"text": "", "class": "idle"}'
fi
