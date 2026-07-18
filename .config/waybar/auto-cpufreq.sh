#!/usr/bin/env bash

# Read actual CPU governor
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

# Read actual battery status & AC state
BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
ADP_ONLINE=$(cat /sys/class/power_supply/ADP0/online 2>/dev/null)

# Read actual max scaling frequency
MAX_FREQ_RAW=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
if [ -n "$MAX_FREQ_RAW" ]; then
    MAX_FREQ=$(awk "BEGIN {printf \"%.1f GHz\", $MAX_FREQ_RAW/1000000}")
else
    MAX_FREQ="N/A"
fi

if [ "$GOV" = "performance" ]; then
    TEXT="⚡"
    CLASS="performance"
    MODE="Performance"
    TURBO="ALWAYS ON"
else
    TEXT="🔋"
    CLASS="powersave"
    MODE="Powersave"
    TURBO="AUTO"
fi

if [ "$BAT_STATUS" = "Discharging" ] || [ "$ADP_ONLINE" = "0" ]; then
    POWER_SRC="Battery Power"
else
    POWER_SRC="AC Charging"
fi

TOOLTIP="Current Mode: ${MODE} (${POWER_SRC})\n----------------------------------------\nGovernor: ${GOV}\nTurbo Boost: ${TURBO}\nMax Clock Speed: ${MAX_FREQ}"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
