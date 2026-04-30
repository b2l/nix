#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

PIDFILE="/tmp/dictate.pid"
WAVFILE="/tmp/dictate.wav"
GROQ_URL="https://api.groq.com/openai/v1/audio/transcriptions"

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
        -F model=whisper-large-v3-turbo 2>/dev/null); then
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
    wtype -M ctrl -M shift v -m shift -m ctrl
    dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Done" -t 2000
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    stop_recording
else
    rm -f "$PIDFILE"
    start_recording
fi
