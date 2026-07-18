#!/usr/bin/env bash

# Path to the charger online state
ADP_PATH="/sys/class/power_supply/ADP0/online"

if [ -f "$ADP_PATH" ] && [ "$(cat "$ADP_PATH")" = "1" ]; then
    # Reset scaling_max_freq of all cores to cpuinfo_max_freq
    for max_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        dir=$(dirname "$max_file")
        if [ -f "$dir/cpuinfo_max_freq" ]; then
            cat "$dir/cpuinfo_max_freq" > "$max_file" 2>/dev/null
        fi
    done
fi
