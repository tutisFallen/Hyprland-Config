#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

# Sync current live config into dotfiles repo
mkdir -p \
  dotfiles/niri/.config/niri \
  dotfiles/gtk/.config/gtk-3.0 \
  dotfiles/gtk/.config/gtk-4.0 \
  dotfiles/fontconfig/.config/fontconfig \
  dotfiles/kitty/.config/kitty \
  dotfiles/thunar/.config/Thunar \
  dotfiles/nvim/.config/nvim \
  dotfiles/waypaper/.config/waypaper \
  dotfiles/localbin/.local/bin

sync_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -e "$src" || -L "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    rsync -a --delete "$src" "$dst"
  fi
}

sync_file_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" || -L "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    rsync -a "$src" "$dst"
  fi
}

sync_if_exists "$HOME/.config/niri/" dotfiles/niri/.config/niri/
sync_file_if_exists "$HOME/.config/gtk-3.0/settings.ini" dotfiles/gtk/.config/gtk-3.0/settings.ini
sync_file_if_exists "$HOME/.config/gtk-3.0/gtk.css" dotfiles/gtk/.config/gtk-3.0/gtk.css
sync_file_if_exists "$HOME/.config/gtk-3.0/dank-colors.css" dotfiles/gtk/.config/gtk-3.0/dank-colors.css
sync_file_if_exists "$HOME/.config/gtk-4.0/settings.ini" dotfiles/gtk/.config/gtk-4.0/settings.ini
sync_file_if_exists "$HOME/.config/gtk-4.0/gtk.css" dotfiles/gtk/.config/gtk-4.0/gtk.css
sync_file_if_exists "$HOME/.config/gtk-4.0/dank-colors.css" dotfiles/gtk/.config/gtk-4.0/dank-colors.css
sync_file_if_exists "$HOME/.config/fontconfig/fonts.conf" dotfiles/fontconfig/.config/fontconfig/fonts.conf
sync_if_exists "$HOME/.config/kitty/" dotfiles/kitty/.config/kitty/
sync_if_exists "$HOME/.config/Thunar/" dotfiles/thunar/.config/Thunar/
sync_if_exists "$HOME/.config/nvim/" dotfiles/nvim/.config/nvim/
sync_if_exists "$HOME/.config/waypaper/" dotfiles/waypaper/.config/waypaper/
sync_file_if_exists "$HOME/.local/bin/waypaper-picker" dotfiles/localbin/.local/bin/waypaper-picker

# cleanup runtime backups/artifacts
find dotfiles -type f -name '*.bak-*' -delete || true

# optional commit + push
if [[ "${1:-}" == "--commit" ]]; then
  msg="${2:-chore: sync current local configs}"
  git add dotfiles scripts README.md .gitignore 2>/dev/null || true
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "$msg"
    git push
    echo "[✓] Synced, committed and pushed"
  else
    echo "[=] Nothing to commit"
  fi
else
  echo "[✓] Synced local files to repo. Review with: git status"
  echo "    Commit with: $0 --commit \"your message\""
fi
