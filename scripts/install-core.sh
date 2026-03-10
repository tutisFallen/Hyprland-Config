#!/usr/bin/env bash
set -euo pipefail

# Core = packages + chezmoi apply + shell setup + fonts
# Usage: ./scripts/install-core.sh [auto|niri|hyprland] [--no-aur]

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSITOR="${1:-auto}"
ENABLE_AUR="true"

for arg in "$@"; do
  case "$arg" in
    auto|niri|hyprland) COMPOSITOR="$arg" ;;
    --no-aur) ENABLE_AUR="false" ;;
  esac
done

echo "[core] Installing distro packages ($COMPOSITOR)"
INSTALL_AUR="$ENABLE_AUR" bash "$ROOT_DIR/scripts/install-packages.sh" "$COMPOSITOR"

if ! command -v chezmoi >/dev/null 2>&1 && command -v "$HOME/.local/bin/chezmoi" >/dev/null 2>&1; then
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "[core] Applying dotfiles with chezmoi"
chezmoi init --apply --source="$ROOT_DIR"

echo "[core] Running shell setup"
bash "$ROOT_DIR/setup-shell.sh"

echo "[core] Refreshing font cache"
fc-cache -fv >/dev/null || true

echo "[core] Done ✅"
