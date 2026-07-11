# dotfile

Personal dotfiles and configuration files for my Linux desktop.

Note: I was unable to list repository contents via the API in order to auto-detect which config files are present. If you want this README tailored to the files that actually exist in this repository, either make the repository public or paste the top-level file list here (or grant the assistant access). The README below is a safe, general template that explains how to use dotfiles to install and configure Hyprland.

---

## Can this repo install Hyprland?
Short answer: No — dotfiles alone do not install software. They only provide configuration files (for example, ~/.config/hypr or ~/.config/waybar). To run Hyprland you must first install the Hyprland compositor and any required packages on your distribution. After that you can apply the config files from this repository by symlinking or copying them into your home directory.

This repository may contain Hyprland-related config files (look for a `hypr`, `hyprland` or `waybar` directory under `.config/`, or files named like `hyprland.conf`, `waybar/config`, `hyprpaper`), but I couldn't scan the repo automatically to confirm.

## Quick checklist — does this repo contain Hyprland configs?
Run these commands in a local clone of this repo to check:

```sh
# from the repo root
ls -la
find . -maxdepth 4 -type d -name "hypr*" -o -name "waybar" -o -path "*/.config/*hypr*"
find . -type f -iname "*hypr*" -o -iname "*hyprland*" -o -iname "waybar*"
```

Look for:
- .config/hypr/ or .config/hyprland/
- hyprland.conf
- waybar/ (configs for status bar)
- eww/ or scripts/ or .local/bin helpers that start things
- shell dotfiles (.bashrc, .zshrc) with autostart entries for desktop apps

## How to use these dotfiles with Hyprland (general steps)
1. Install Hyprland and dependencies for your distribution.
   - Arch / Manjaro (example):
     ```sh
     sudo pacman -Syu hyprland hyprpaper waybar wl-clipboard grim slurp wlroots foot alacritty wofi pamixer gammastep
     ```
     (Package names may vary; check your distribution's repositories or the AUR.)
   - Debian/Ubuntu/Fedora: Hyprland may not be available in official repos; look for distribution packages, COPR, or build from source, or use a distribution with official Hyprland packages.

2. Backup your current configs:

```sh
mkdir -p ~/.config/backup-dotfiles-$(date +%Y%m%d)
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/backup-dotfiles-$(date +%Y%m%d)/
[ -f ~/.config/hypr/hyprland.conf ] && mv ~/.config/hypr/hyprland.conf ~/.config/backup-dotfiles-$(date +%Y%m%d)/
```

3. Apply configs from this repo. If the repo contains `.config/hypr` and other files, symlink them into place (example assuming you cloned the repo to ~/dotfile):

```sh
cd ~
git clone git@github.com:Gaurav5189/dotfile.git ~/dotfile
ln -sfn ~/dotfile/.config/hypr ~/.config/hypr
ln -sfn ~/dotfile/.config/waybar ~/.config/waybar   # if present
ln -sfn ~/dotfile/.config/eww ~/.config/eww         # if present
```

4. Install any tools referenced by the configs (waybar modules, eww, hyprpaper, notification daemon, compositor helpers) and ensure they are in your PATH.

5. Start Hyprland
- From a Wayland-capable login manager choose the Hyprland session (if available), or
- Run it manually from a TTY that supports Wayland sessions: `Hyprland` (the exact command may vary).

6. If things fail, check the Hyprland log (often printed to your TTY) and the config file paths. Some config options depend on helper scripts or programs (e.g., hyprpaper, eww, waybar modules).

## Troubleshooting tips
- If your bar is empty or widgets do not appear, open a terminal and run the bar (waybar) manually to see errors.
- Missing icons or fonts: ensure Nerd Fonts or configured fonts are installed.
- If a keybind does nothing, confirm the config file in use and that Hyprland was restarted after edits.

## If you want a tailored README
I can update this README to reflect the exact files in the repo and provide precise symlink commands and dependency lists. To do that I need either:
- the repository to be made public so I can scan it, or
- a pasted list of top-level files (output of `ls -la`), or
- permission to read repository contents from this session.

---

If you want, I will add this README to the repository now (it will create README.md in the default branch). If you'd like a different message or more detail (example install commands for a specific distro), tell me which distro you use and whether you want the README committed to the repo now.