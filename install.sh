#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

COMPOSITOR="${1:-auto}" # auto|niri|hyprland

if [[ "$COMPOSITOR" == "auto" ]]; then
  env_lc="${XDG_CURRENT_DESKTOP:-} ${DESKTOP_SESSION:-}"
  env_lc="${env_lc,,}"
  if [[ "$env_lc" == *"niri"* ]]; then
    COMPOSITOR="niri"
  elif [[ "$env_lc" == *"hypr"* ]]; then
    COMPOSITOR="hyprland"
  elif need_cmd niri; then
    COMPOSITOR="niri"
  else
    COMPOSITOR="hyprland"
  fi
fi

if ! need_cmd stow; then
  echo "[+] Installing stow..."
  sudo pacman -S --needed stow
fi

BASE_PKGS=(kitty yazi thunar fzf eza neovim starship rsync mpv playerctl socat flatpak python-gobject python-imageio python-imageio-ffmpeg python-screeninfo python-platformdirs nwg-look)
FONT_PKGS=(ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts noto-fonts-emoji noto-fonts-cjk otf-font-awesome)
THEME_PKGS=(adwaita-icon-theme papirus-icon-theme arc-gtk-theme materia-gtk-theme)
AUR_PKGS=(waypaper mpvpaper catppuccin-gtk-theme-mocha whitesur-gtk-theme)

if [[ "$COMPOSITOR" == "niri" ]]; then
  WM_PKGS=(niri waybar xdg-desktop-portal-gnome xdg-desktop-portal-gtk)
  WM_STOW=(niri)
  WM_REMOVE=(hypr)
else
  WM_PKGS=(hyprland hypridle hyprlock waybar xdg-desktop-portal-hyprland)
  WM_STOW=(hypr)
  WM_REMOVE=(niri)
fi

COMMON_STOW=(kitty nvim quickshell shell starship thunar yazi gtk fontconfig waypaper localbin)

FLATPAK_APPS=(
  be.alexandervanhee.gradia
  com.brave.Browser
  com.dec05eba.gpu_screen_recorder
  com.spotify.Client
  com.vscodium.codium
  com.vysp3r.ProtonPlus
  io.github.IshuSinghSE.aurynk
  io.github.kolunmi.Bazaar
  io.github.ltiber.Pwall
  io.github.swordpuffin.wardrobe
  org.prismlauncher.PrismLauncher
)

echo "[+] Compositor target: $COMPOSITOR"
echo "[+] Installing base packages"
sudo pacman -S --needed "${BASE_PKGS[@]}" "${FONT_PKGS[@]}" "${THEME_PKGS[@]}" "${WM_PKGS[@]}"

echo "[+] Installing AUR stack: wallpaper + GTK themes"
if need_cmd yay; then
  yay -S --needed --noconfirm "${AUR_PKGS[@]}"
else
  echo "[!] yay not found. Install manually (AUR): ${AUR_PKGS[*]}"
fi

echo "[+] Installing Flatpaks"
if ! need_cmd flatpak; then
  echo "[!] flatpak não encontrado após instalação de pacotes base."
else
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
  for app in "${FLATPAK_APPS[@]}"; do
    flatpak install -y flathub "$app" || true
  done
fi

echo "[+] Applying common dotfiles"
stow -v -R -d dotfiles -t "$HOME" "${COMMON_STOW[@]}"

echo "[+] Applying compositor dotfiles: ${WM_STOW[*]}"
stow -v -R -d dotfiles -t "$HOME" "${WM_STOW[@]}"

echo "[+] Removing inactive compositor dotfiles: ${WM_REMOVE[*]}"
for pkg in "${WM_REMOVE[@]}"; do
  stow -v -D -d dotfiles -t "$HOME" "$pkg" || true
done

bash ./setup-shell.sh
fc-cache -fv >/dev/null || true

echo "[✓] Setup complete. Open a new terminal/session."
