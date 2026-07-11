#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

DOCK_THEME="modern"
if [ -f $HOME/.config/ml4w/settings/dock-theme ]; then
    DOCK_THEME=$(cat $HOME/.config/ml4w/settings/dock-theme)
fi
echo ":: Using Dock Theme $DOCK_THEME"
echo ":: Dock Autohide $DOCK_AUTOHIDE"
if [ ! -f $HOME/.config/ml4w/settings/dock-disabled ]; then
    killall nwg-dock-hyprland
    sleep 0.5
    if [ -f $HOME/.config/ml4w/settings/dock-autohide ]; then
        nwg-dock-hyprland -d -hd 60 -i 32 -w 5 -mb 10 -x -o -s themes/$DOCK_THEME/style.css
    else
        nwg-dock-hyprland -i 32 -w 5 -mb 10 -x -o -s themes/$DOCK_THEME/style.css -c "$HOME/.config/nwg-dock-hyprland/custom_launcher.desktop"
    fi
else
    killall nwg-dock-hyprland
    echo ":: Dock disabled"
fi
