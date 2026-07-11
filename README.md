# Dotfiles (ML4W-based Hyprland Setup)

Welcome to my personal dotfiles repository! This repository stores my customized desktop configurations, built on top of the **ML4W (My Linux for Work)** dotfiles suite. It provides a complete, modern, and highly aesthetic tiling window manager environment using Hyprland on Linux.

---

## 🛠️ Desktop Environment Components

This repository contains configurations for the following tools:

| Component | Tool / Application | Description |
| :--- | :--- | :--- |
| **Window Manager** | [Hyprland](https://hyprland.org/) | A dynamic tiling Wayland compositor with beautiful animations. |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) | A fast, feature-rich, GPU-accelerated terminal emulator. |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) | Highly customizable Wayland bar for system monitoring and workspace control. |
| **App Launcher** | [Rofi](https://github.com/davatorium/rofi) / [Walker](https://github.com/abenz12/walker) | Clean application launcher, clipboard manager, and utility menu. |
| **Notifications** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Sway Notification Center for managing desktop notifications. |
| **Theme Engine** | [Matugen](https://github.com/InIOuT/matugen) | Material You color generator for dynamic wallpaper-based colors. |
| **Shells** | Bash, Fish, Zsh | Shell integrations with custom aliases and autostart scripts. |
| **Prompt** | [Starship](https://starship.rs/) / [Oh My Posh](https://ohmyposh.dev/) | Cross-shell prompts for rich terminal statuses. |
| **Wallpaper** | [Waypaper](https://github.com/danbhang/waypaper) | Graphical frontend to set wallpapers with Hyprpaper. |
| **System Monitor** | [Btop](https://github.com/aristocratos/btop) | Aesthetic terminal-based resource monitor. |
| **Session Control** | [Wlogout](https://github.com/ArtsyFartsy/wlogout) | Elegant Wayland logout menu overlay. |

---

## 📂 Repository Structure

* **`.config/`**: Contains core application configuration folders:
  * `hypr/` – Hyprland window manager rules, keybinds, and startup applications.
  * `kitty/` – Terminal looks, shortcuts, and matugen integration.
  * `waybar/` – Desktop bar layout and styling themes.
  * `wlogout/` – Logout, restart, and shutdown menu layouts.
  * `swaync/` – Notification styling and widget setups.
  * `rofi/` – Clean app menus and theme switchers.
  * `fastfetch/` – Custom system information display template.
  * `fish/` & `bashrc/` – Custom shell profiles, functions, and autostarts.
  * `gtk-3.0/` & `gtk-4.0/` – Dynamic GTK system theme colors.
* **Home Dotfiles**:
  * `.bashrc` & `.zshrc` – User shell environment configurations.
  * `.gtkrc-2.0` & `.Xresources` – Fallback themes and font setups.

---

## 🚀 How to Apply / Restore These Dotfiles

If you want to apply these dotfiles on a new installation:

### 1. Clone the repository
Clone the repository to your custom dotfiles directory:
```bash
git clone https://github.com/Gaurav5189/dotfile.git ~/.mydotfiles/com.ml4w.dotfiles
```

### 2. Link the configuration files
Ensure you back up any existing configurations in `~/.config` first, then link the folders from this repository to your target locations:

```bash
# Create target directory if it doesn't exist
mkdir -p ~/.config

# Symlink dotfiles into home directory
ln -sf ~/.mydotfiles/com.ml4w.dotfiles/.bashrc ~/.bashrc
ln -sf ~/.mydotfiles/com.ml4w.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.mydotfiles/com.ml4w.dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0
ln -sf ~/.mydotfiles/com.ml4w.dotfiles/.Xresources ~/.Xresources

# Symlink all config directories
for dir in hypr kitty waybar wlogout swaync rofi fastfetch fish bashrc btop gtk-3.0 gtk-4.0 matugen ohmyposh qt6ct quickshell walker waypaper xsettingsd; do
    if [ -d ~/.mydotfiles/com.ml4w.dotfiles/.config/$dir ]; then
        # Back up existing config folder if it is not a symlink
        [ -d ~/.config/$dir ] && [ ! -L ~/.config/$dir ] && mv ~/.config/$dir ~/.config/${dir}_backup
        
        # Link the folder
        ln -sfn ~/.mydotfiles/com.ml4w.dotfiles/.config/$dir ~/.config/$dir
    fi
done
```
---

## Link to original Repo
```
https://github.com/mylinuxforwork/dotfiles
```
