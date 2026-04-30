#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

PIDFILE="/tmp/dictate.pid"
WAVFILE="/tmp/dictate.wav"
GROQ_URL="https://api.groq.com/openai/v1/audio/transcriptions"
VOCAB="NixOS, nixpkgs, Xwayland, Wayland, Hyprland, hyprctl, waybar, dunstify, wtype, Neovim, Catppuccin, ebean, Liquibase, FastAPI, Uvicorn, OpenFeign, Lombok, MapStruct, WireMock, Pitest, MangoPay, Chargebee, Algolia, TanStack Query, Redux-Saga, Grommet, antd, shadcn/ui, Tailwind, PostCSS, Webpack, Storybook, Chromatic, pnpm, Claude Code, Groq, Whisper, OpenTofu, Fargate, CloudFront, ElastiCache, Karapace, Kpow, Aiven, Consul, Datadog, Sentry, Metabase, Airflow, SonarQube, Aikido, Alembic, SQLAlchemy, asyncpg, jujutsu, lazygit, direnv, ripgrep, Hookdeck, Deadbolt, Guice, sbt, PipeWire, Passbolt, Dvorak"

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

    if [ -z "$pid" ] || ! kill -INT "$pid" 2>/dev/null; then
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
    if ! response=$(curl -sf --connect-timeout 5 --max-time 30 "$GROQ_URL" \
        -H "Authorization: Bearer $api_key" \
        -F file=@"$WAVFILE" \
        -F model=whisper-large-v3-turbo \
        -F language=fr \
        -F prompt="$VOCAB" 2>/dev/null); then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: API request failed" -t 3000
        return 1
    fi

    local text
    text=$(echo "$response" | jq -r '.text // empty')
    if [ -z "$text" ]; then
        dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: empty transcription" -t 3000
        return 1
    fi

    wl-copy "$text"
    wtype -M ctrl v -m ctrl
    dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Done" -t 2000
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    stop_recording
else
    rm -f "$PIDFILE"
    start_recording
fi
