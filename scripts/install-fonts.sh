#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
mkdir -p "$FONT_DIR"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "[fonts] Installing Inter Variable"
curl -fL "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" -o "$tmp/Inter.zip"
unzip -jo "$tmp/Inter.zip" "InterVariable.ttf" "InterVariable-Italic.ttf" -d "$FONT_DIR" >/dev/null

echo "[fonts] Installing Fira Code"
curl -fL "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o "$tmp/FiraCode.zip"
unzip -jo "$tmp/FiraCode.zip" "ttf/*.ttf" -d "$FONT_DIR" >/dev/null

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f
fi

echo "[fonts] Done ✅ Installed in: $FONT_DIR"
