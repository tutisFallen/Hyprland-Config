#!/usr/bin/env bash

# Generic package groups mapped per distro family.
# Keys are logical names used by install scripts.

declare -Ag PKG_MAP_PACMAN
declare -Ag PKG_MAP_DNF
declare -Ag PKG_MAP_APT
declare -Ag PKG_MAP_ZYPPER
declare -Ag PKG_MAP_XBPS

# Core tools
PKG_MAP_PACMAN[core]="git curl ca-certificates rsync"
PKG_MAP_DNF[core]="git curl ca-certificates rsync"
PKG_MAP_APT[core]="git curl ca-certificates rsync"
PKG_MAP_ZYPPER[core]="git curl ca-certificates rsync"
PKG_MAP_XBPS[core]="git curl ca-certificates rsync"

# CLI / terminal stack
PKG_MAP_PACMAN[cli]="kitty yazi thunar fzf eza neovim starship"
PKG_MAP_DNF[cli]="kitty yazi thunar fzf eza neovim starship"
PKG_MAP_APT[cli]="kitty yazi thunar fzf eza neovim"
PKG_MAP_ZYPPER[cli]="kitty yazi thunar fzf eza neovim"
PKG_MAP_XBPS[cli]="kitty yazi thunar fzf eza neovim"

# Desktop helpers
PKG_MAP_PACMAN[desktop]="mpv playerctl socat flatpak nwg-look"
PKG_MAP_DNF[desktop]="mpv playerctl socat flatpak nwg-look"
PKG_MAP_APT[desktop]="mpv playerctl socat flatpak"
PKG_MAP_ZYPPER[desktop]="mpv playerctl socat flatpak"
PKG_MAP_XBPS[desktop]="mpv playerctl socat flatpak"

# Python helpers used by wallpaper/tooling
PKG_MAP_PACMAN[python]="python-gobject python-imageio python-imageio-ffmpeg python-screeninfo python-platformdirs"
PKG_MAP_DNF[python]="python3-gobject python3-imageio python3-imageio-ffmpeg python3-screeninfo python3-platformdirs"
PKG_MAP_APT[python]="python3-gi python3-imageio python3-imageio-ffmpeg python3-screeninfo python3-platformdirs"
PKG_MAP_ZYPPER[python]="python3-gobject python3-imageio python3-imageio-ffmpeg python3-screeninfo python3-platformdirs"
PKG_MAP_XBPS[python]="python3-gobject python3-imageio python3-imageio-ffmpeg python3-screeninfo python3-platformdirs"

# Fonts
PKG_MAP_PACMAN[fonts]="ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts noto-fonts-emoji noto-fonts-cjk otf-font-awesome"
PKG_MAP_DNF[fonts]="jetbrains-mono-fonts-all google-noto-emoji-fonts google-noto-sans-cjk-fonts fontawesome-fonts-all"
PKG_MAP_APT[fonts]="fonts-jetbrains-mono fonts-noto-color-emoji fonts-noto-cjk fonts-font-awesome"
PKG_MAP_ZYPPER[fonts]="jetbrains-mono-fonts noto-coloremoji-fonts noto-sans-cjk-fonts fontawesome-fonts"
PKG_MAP_XBPS[fonts]="font-jetbrains-mono font-noto-emoji noto-fonts-cjk font-awesome"

# GTK themes/icons
PKG_MAP_PACMAN[themes]="adwaita-icon-theme papirus-icon-theme arc-gtk-theme materia-gtk-theme"
PKG_MAP_DNF[themes]="adwaita-icon-theme papirus-icon-theme arc-theme materia-gtk-theme"
PKG_MAP_APT[themes]="adwaita-icon-theme papirus-icon-theme arc-theme"
PKG_MAP_ZYPPER[themes]="adwaita-icon-theme papirus-icon-theme arc-theme"
PKG_MAP_XBPS[themes]="adwaita-icon-theme papirus-icon-theme arc-theme"

# Compositor stack
PKG_MAP_PACMAN[niri]="niri waybar xdg-desktop-portal-gnome xdg-desktop-portal-gtk"
PKG_MAP_DNF[niri]="niri waybar xdg-desktop-portal-gnome xdg-desktop-portal-gtk"
PKG_MAP_APT[niri]="waybar xdg-desktop-portal-gtk"
PKG_MAP_ZYPPER[niri]="waybar xdg-desktop-portal-gtk"
PKG_MAP_XBPS[niri]="waybar xdg-desktop-portal-gtk"

PKG_MAP_PACMAN[hyprland]="hyprland hypridle hyprlock waybar xdg-desktop-portal-hyprland"
PKG_MAP_DNF[hyprland]="hyprland hypridle hyprlock waybar xdg-desktop-portal-hyprland"
PKG_MAP_APT[hyprland]="hyprland waybar xdg-desktop-portal-hyprland"
PKG_MAP_ZYPPER[hyprland]="hyprland waybar xdg-desktop-portal-hyprland"
PKG_MAP_XBPS[hyprland]="hyprland waybar xdg-desktop-portal-hyprland"
