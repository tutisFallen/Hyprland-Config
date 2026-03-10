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

echo "[setup] Running core installer ($COMPOSITOR)..."
if [[ "$ENABLE_AUR" == "true" ]]; then
  bash "$ROOT_DIR/scripts/install-core.sh" "$COMPOSITOR"
else
  bash "$ROOT_DIR/scripts/install-core.sh" "$COMPOSITOR" --no-aur
fi

if [[ "$ENABLE_FLATPAK" == "true" ]] && ask_yes_no "Install Flatpak app set?"; then
  bash "$ROOT_DIR/scripts/install-apps.sh"
fi

echo "[setup] Done ✅"
