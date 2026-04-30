#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

PIDFILE="/tmp/dictate.pid"
WAVFILE="/tmp/dictate.wav"
GROQ_URL="https://api.groq.com/openai/v1/audio/transcriptions"
VOCAB="NixOS, Xwayland, Wayland, Hyprland, Docker, Docker Compose, React, ReactJS, TypeScript, JavaScript, Terraform, AWS, ebean, Java, Python, Cython, Poetry, uv, venv, pip, TanStack Query, Redux, Redux-Saga, Grommet, Ant Design, antd, shadcn/ui, Tailwind, CSS, Less, Claude, Claude Code, useEffect, useState, npm, pnpm, git, GitHub"

start_recording() {
    rec -q "$WAVFILE" rate 16k channels 1 &
    echo $! > "$PIDFILE"
    dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Recording..." -t 0
    pkill -SIGRTMIN+2 waybar
}

stop_recording() {
    local pid
    pid=$(cat "$PIDFILE" 2>/dev/null)
    rm -f "$PIDFILE"
    pkill -SIGRTMIN+2 waybar

    if [ -z "$pid" ] || ! kill "$pid" 2>/dev/null; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: no active recording" -t 3000
        return 1
    fi
    # Give rec a moment to flush the file
    sleep 0.2

    if [ ! -s "$WAVFILE" ]; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: empty audio file" -t 3000
        return 1
    fi

    local api_key
    api_key=$(secret-tool lookup all groq 2>/dev/null)
    if [ -z "$api_key" ]; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: no API key found" -t 3000
        return 1
    fi

    dunstify -a "Dictate" -r 9994 -i content-loading-symbolic "Dictation" "Transcribing..." -t 0

    local response
    response=$(curl -sf --max-time 10 "$GROQ_URL" \
        -H "Authorization: Bearer $api_key" \
        -F file=@"$WAVFILE" \
        -F model=whisper-large-v3-turbo \
        -F language=fr \
        -F prompt="$VOCAB" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$response" ]; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: API request failed" -t 3000
        return 1
    fi

    local text
    text=$(echo "$response" | jq -r '.text // empty')
    if [ -z "$text" ]; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: empty transcription" -t 3000
        return 1
    fi

    wtype -- "$text"
    dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Done" -t 2000
    rm -f "$WAVFILE"
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    stop_recording
else
    rm -f "$PIDFILE"
    start_recording
fi
