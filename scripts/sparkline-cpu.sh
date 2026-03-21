#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:$PATH"
# Rolling sparkline for CPU usage — outputs JSON for waybar custom module
BARS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
HISTORY_FILE="/tmp/waybar-cpu-history"
PREV_FILE="/tmp/waybar-cpu-prev"
WIDTH=6

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total=$((user + nice + system + idle + iowait + irq + softirq + steal))

if [[ -f "$PREV_FILE" ]]; then
    read -r prev_total prev_idle < "$PREV_FILE"
    diff_total=$((total - prev_total))
    diff_idle=$((idle - prev_idle))
    if (( diff_total > 0 )); then
        usage=$(( 100 * (diff_total - diff_idle) / diff_total ))
    else
        usage=0
    fi
else
    usage=0
fi

echo "$total $idle" > "$PREV_FILE"
echo "$usage" >> "$HISTORY_FILE"
tail -n "$WIDTH" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

spark=""
while IFS= read -r val; do
    idx=$(( val * 7 / 100 ))
    (( idx > 7 )) && idx=7
    (( idx < 0 )) && idx=0
    spark+="${BARS[$idx]}"
done < "$HISTORY_FILE"

printf '{"text": "%s %s%%", "tooltip": "CPU: %s%%", "class": "sparkline"}\n' "$spark" "$usage" "$usage"
