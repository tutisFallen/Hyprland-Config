#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd stow; then
  echo "[+] Instalando stow..."
  sudo pacman -S --needed stow
fi

echo "[+] Instalando base CLI/UI..."
sudo pacman -S --needed kitty yazi thunar fzf eza neovim starship

if need_cmd yay; then
  echo "[+] yay detectado (AUR disponível)"
else
  echo "[!] yay não encontrado (ok por enquanto)"
fi

echo "[+] Aplicando dotfiles"
stow -v -R -t "$HOME" dotfiles

bash ./setup-shell.sh

echo "[✓] Setup aplicado. Abra um novo terminal para carregar aliases/starship."
