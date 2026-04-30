#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"

PIDFILE="/tmp/dictate.pid"
WAVFILE="/tmp/dictate.wav"
GROQ_URL="https://api.groq.com/openai/v1/audio/transcriptions"

# If already recording, cancel
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    kill -INT "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    pkill -SIGRTMIN+2 waybar
    dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Cancelled" -t 2000
    exit 0
fi

# Start recording — auto-stops after 2s of silence
echo $$ > "$PIDFILE"
dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Recording..." -t 0
pkill -SIGRTMIN+2 waybar

rec -q "$WAVFILE" rate 16k channels 1 silence 1 0.1 3% 1 2.0 3%

# rec finished (silence detected or killed)
rm -f "$PIDFILE"
pkill -SIGRTMIN+2 waybar

if [ ! -s "$WAVFILE" ]; then
    dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: empty audio file" -t 3000
    exit 1
fi

api_key=$(secret-tool lookup all groq 2>/dev/null)
if [ -z "$api_key" ]; then
    dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: no API key found" -t 3000
    exit 1
fi

dunstify -a "Dictate" -r 9994 -i content-loading-symbolic "Dictation" "Transcribing..." -t 0

if ! response=$(curl -sf --connect-timeout 5 --max-time 30 "$GROQ_URL" \
    -H "Authorization: Bearer $api_key" \
    -F file=@"$WAVFILE" \
    -F model=whisper-large-v3-turbo 2>/dev/null); then
    dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: API request failed" -t 3000
    exit 1
fi

text=$(echo "$response" | jq -r '.text // empty')
if [ -z "$text" ]; then
    dunstify -a "Dictate" -r 9994 -i dialog-error-symbolic "Dictation" "Error: empty transcription" -t 3000
    exit 1
fi

wl-copy "$text"
wtype -M ctrl v -m ctrl
dunstify -a "Dictate" -r 9994 -i microphone-sensitivity-high-symbolic "Dictation" "Done" -t 2000
