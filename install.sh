#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "[+] stow não encontrado. Instalando..."
  sudo pacman -S --needed stow
fi

echo "[+] Aplicando dotfiles"
stow -v -R -t "$HOME" dotfiles

echo "[✓] Pronto"
