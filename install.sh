#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "[+] Instalando stow..."
  sudo pacman -S --needed stow
fi

echo "[+] Aplicando dotfiles com stow"
stow -v -R -t "$HOME" dotfiles

echo "[✓] Dotfiles aplicados. Reinicie a sessão do Hyprland."
