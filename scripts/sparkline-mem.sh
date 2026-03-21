#!/usr/bin/env bash
# Rolling sparkline for memory usage — outputs JSON for waybar custom module
BARS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
HISTORY_FILE="/tmp/waybar-mem-history"
WIDTH=6

usage=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
used=$(free -h | awk '/^Mem:/ {print $3}')

echo "$usage" >> "$HISTORY_FILE"
tail -n "$WIDTH" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

spark=""
while IFS= read -r val; do
    idx=$(( val * 7 / 100 ))
    (( idx > 7 )) && idx=7
    (( idx < 0 )) && idx=0
    spark+="${BARS[$idx]}"
done < "$HISTORY_FILE"

printf '{"text": "%s %s", "tooltip": "RAM: %s (%s%%)", "class": "sparkline"}\n' "$spark" "$used" "$used" "$usage"
