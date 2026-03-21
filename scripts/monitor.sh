#!/usr/bin/env bash

# Monitor management wrapper for hyprctl
# Usage: monitor.sh [command] [options]

set -e

INTERNAL="eDP-1"

# Get the first connected external monitor (HDMI or DP)
get_external() {
    hyprctl monitors all -j | jq -r '.[] | select(.name | test("^(HDMI|DP)")) | .name' | head -n1
}

# Show help
show_help() {
    cat <<EOF
Monitor management for Hyprland

Usage: monitor.sh [command] [display]

Commands:
  list, ls              List all monitors
  mirror                Mirror internal to external display
  extend                Extend desktop to external display (side-by-side)
  off <display>         Turn off specified display
  on <display>          Turn on specified display
  only <display>        Turn on only the specified display
  help                  Show this help message

Display aliases:
  internal, i           Internal laptop display ($INTERNAL)
  external, e           External display (auto-detected)

Examples:
  monitor.sh list
  monitor.sh mirror
  monitor.sh extend
  monitor.sh off internal
  monitor.sh on external
  monitor.sh only external
EOF
}

# List monitors
list_monitors() {
    echo "Connected monitors:"
    hyprctl monitors all | grep -E "Monitor|disabled"
}

# Mirror displays
mirror_displays() {
    EXTERNAL=$(get_external)
    if [[ -z "$EXTERNAL" ]]; then
        echo "Error: No external monitor detected"
        exit 1
    fi

    echo "Mirroring $INTERNAL to $EXTERNAL"
    hyprctl keyword monitor "$INTERNAL,1920x1080,0x0,1"
    hyprctl keyword monitor "$EXTERNAL,1920x1080,0x0,1,mirror,$INTERNAL"
}

# Extend displays
extend_displays() {
    EXTERNAL=$(get_external)
    if [[ -z "$EXTERNAL" ]]; then
        echo "Error: No external monitor detected"
        exit 1
    fi

    echo "Extending $INTERNAL to $EXTERNAL (side-by-side)"
    hyprctl keyword monitor "$INTERNAL,1920x1080,0x0,1"
    hyprctl keyword monitor "$EXTERNAL,preferred,1920x0,1"
}

# Turn off a display
turn_off() {
    local display="$1"

    case "$display" in
        internal|i)
            display="$INTERNAL"
            ;;
        external|e)
            display=$(get_external)
            if [[ -z "$display" ]]; then
                echo "Error: No external monitor detected"
                exit 1
            fi
            ;;
    esac

    echo "Turning off $display"
    hyprctl keyword monitor "$display,disable"
}

# Turn on a display
turn_on() {
    local display="$1"

    case "$display" in
        internal|i)
            display="$INTERNAL"
            ;;
        external|e)
            display=$(get_external)
            if [[ -z "$display" ]]; then
                echo "Error: No external monitor detected"
                exit 1
            fi
            ;;
    esac

    echo "Turning on $display"
    hyprctl keyword monitor "$display,preferred,auto,1"
}

# Turn on only specified display
only_display() {
    local display="$1"
    local EXTERNAL=$(get_external)

    case "$display" in
        internal|i)
            echo "Enabling only internal display"
            hyprctl keyword monitor "$INTERNAL,preferred,auto,1"
            if [[ -n "$EXTERNAL" ]]; then
                hyprctl keyword monitor "$EXTERNAL,disable"
            fi
            ;;
        external|e)
            if [[ -z "$EXTERNAL" ]]; then
                echo "Error: No external monitor detected"
                exit 1
            fi
            echo "Enabling only external display"
            hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
            hyprctl keyword monitor "$INTERNAL,disable"
            ;;
        *)
            echo "Error: Invalid display. Use 'internal' or 'external'"
            exit 1
            ;;
    esac
}

# Main command router
case "${1:-help}" in
    list|ls)
        list_monitors
        ;;
    mirror)
        mirror_displays
        ;;
    extend)
        extend_displays
        ;;
    off)
        if [[ -z "$2" ]]; then
            echo "Error: Please specify a display (internal/external)"
            exit 1
        fi
        turn_off "$2"
        ;;
    on)
        if [[ -z "$2" ]]; then
            echo "Error: Please specify a display (internal/external)"
            exit 1
        fi
        turn_on "$2"
        ;;
    only)
        if [[ -z "$2" ]]; then
            echo "Error: Please specify a display (internal/external)"
            exit 1
        fi
        only_display "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
