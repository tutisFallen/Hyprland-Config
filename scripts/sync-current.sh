#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

# Sync current live config into chezmoi layout (home/)
mkdir -p \
  home/dot_config/niri \
  home/dot_config/gtk-3.0 \
  home/dot_config/gtk-4.0 \
  home/dot_config/fontconfig \
  home/dot_config/kitty \
  home/dot_config/Thunar \
  home/dot_config/nvim \
  home/dot_config/waypaper \
  home/dot_local/bin

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

sync_if_exists "$HOME/.config/niri/" home/dot_config/niri/
sync_file_if_exists "$HOME/.config/gtk-3.0/settings.ini" home/dot_config/gtk-3.0/settings.ini
sync_file_if_exists "$HOME/.config/gtk-3.0/gtk.css" home/dot_config/gtk-3.0/gtk.css
sync_file_if_exists "$HOME/.config/gtk-3.0/dank-colors.css" home/dot_config/gtk-3.0/dank-colors.css
sync_file_if_exists "$HOME/.config/gtk-4.0/settings.ini" home/dot_config/gtk-4.0/settings.ini
sync_file_if_exists "$HOME/.config/gtk-4.0/gtk.css" home/dot_config/gtk-4.0/gtk.css
sync_file_if_exists "$HOME/.config/gtk-4.0/dank-colors.css" home/dot_config/gtk-4.0/dank-colors.css
sync_file_if_exists "$HOME/.config/fontconfig/fonts.conf" home/dot_config/fontconfig/fonts.conf
sync_if_exists "$HOME/.config/kitty/" home/dot_config/kitty/
sync_if_exists "$HOME/.config/Thunar/" home/dot_config/Thunar/
sync_if_exists "$HOME/.config/nvim/" home/dot_config/nvim/
sync_if_exists "$HOME/.config/waypaper/" home/dot_config/waypaper/
sync_file_if_exists "$HOME/.local/bin/waypaper-picker" home/dot_local/bin/waypaper-picker

# cleanup runtime backups/artifacts
find home -type f -name '*.bak-*' -delete || true

# optional commit + push
if [[ "${1:-}" == "--commit" ]]; then
  msg="${2:-chore: sync current local configs}"
  git add home scripts README.md .gitignore 2>/dev/null || true
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "$msg"
    git push
    echo "[✓] Synced, committed and pushed"
  else
    echo "[=] Nothing to commit"
  fi
else
  echo "[✓] Synced local files to repo (home/). Review with: git status"
  echo "    Commit with: $0 --commit \"your message\""
fi
