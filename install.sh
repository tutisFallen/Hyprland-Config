#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./install.sh [auto|niri|hyprland] [--yes] [--no-flatpak] [--no-aur]

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSITOR="auto"
ASSUME_YES="false"
ENABLE_FLATPAK="true"
ENABLE_AUR="true"

for arg in "$@"; do
  case "$arg" in
    auto|niri|hyprland) COMPOSITOR="$arg" ;;
    --yes|-y) ASSUME_YES="true" ;;
    --no-flatpak) ENABLE_FLATPAK="false" ;;
    --no-aur) ENABLE_AUR="false" ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [auto|niri|hyprland] [--yes] [--no-flatpak] [--no-aur]" >&2
      exit 1
      ;;
  esac
done

ask_yes_no() {
  local prompt="$1" reply
  if [[ "$ASSUME_YES" == "true" ]]; then
    return 0
  fi
  read -r -p "$prompt [y/N] " reply
  reply="${reply,,}"
  [[ "$reply" == "y" || "$reply" == "yes" ]]
}

echo "[setup] Installing distro packages ($COMPOSITOR)..."
INSTALL_AUR="$ENABLE_AUR" bash "$ROOT_DIR/scripts/install-packages.sh" "$COMPOSITOR"

if ! command -v chezmoi >/dev/null 2>&1 && command -v "$HOME/.local/bin/chezmoi" >/dev/null 2>&1; then
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "[setup] Applying dotfiles with chezmoi..."
chezmoi init --apply --source="$ROOT_DIR"

if [[ "$ENABLE_FLATPAK" == "true" ]]; then
  if ask_yes_no "Install Flatpak app set?"; then
    if command -v flatpak >/dev/null 2>&1; then
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
      flatpak install -y flathub \
        be.alexandervanhee.gradia \
        com.brave.Browser \
        com.dec05eba.gpu_screen_recorder \
        com.spotify.Client \
        com.vscodium.codium \
        com.vysp3r.ProtonPlus \
        io.github.IshuSinghSE.aurynk \
        io.github.kolunmi.Bazaar \
        io.github.ltiber.Pwall \
        io.github.swordpuffin.wardrobe \
        org.prismlauncher.PrismLauncher || true
    else
      echo "[setup][warn] flatpak not installed; skipping Flatpak apps"
    fi
  fi
fi

echo "[setup] Running shell setup"
bash "$ROOT_DIR/setup-shell.sh"

echo "[setup] Refreshing font cache"
fc-cache -fv >/dev/null || true

echo "[setup] Done ✅"
