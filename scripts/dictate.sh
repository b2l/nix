#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

PIDFILE="/tmp/dictate.pid"
WAVFILE="/tmp/dictate.wav"
GROQ_URL="https://api.groq.com/openai/v1/audio/transcriptions"
VOCAB="NixOS, nixpkgs, Xwayland, Wayland, Hyprland, hyprctl, waybar, dunst, dunstify, wtype, tmux, foot, Neovim, nvim, Catppuccin, ebean, Liquibase, FastAPI, Uvicorn, Connexion, Spring Boot, OpenFeign, Lombok, MapStruct, JUnit, Mockito, WireMock, Pitest, MangoPay, Chargebee, Algolia, TanStack Query, Redux, Redux-Saga, Grommet, Ant Design, antd, shadcn/ui, Tailwind, PostCSS, Webpack, Vite, NX, Storybook, Chromatic, Cypress, Jest, pnpm, Claude, Claude Code, Groq, Whisper, Terraform, OpenTofu, Fargate, CloudFront, ElastiCache, Kafka, Avro, Karapace, Kpow, Aiven, Consul, Datadog, Sentry, PostgreSQL, Metabase, Elasticsearch, Docker Compose, Airflow, Bitbucket, GitHub Actions, SonarQube, Aikido, Poetry, uv, venv, Alembic, SQLAlchemy, asyncpg, jujutsu, lazygit, direnv, ripgrep, Ansible, Hookdeck, Deadbolt, Guice, sbt, Play Framework, Scala, Kotlin, Deno, Rust, cargo, useEffect, useState, rsync, nginx, SDDM, systemd, PipeWire, rbw, Passbolt, Dvorak"

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
