#!/usr/bin/env bash
set -euo pipefail

TARGET_BASHRC="$HOME/.bashrc"

ensure_line() {
  local line="$1"
  local file="$2"
  grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

touch "$TARGET_BASHRC"
ensure_line '' "$TARGET_BASHRC"
ensure_line '# Hyprland-Config shell stack' "$TARGET_BASHRC"
ensure_line '[ -f "$HOME/.config/shell/env.sh" ] && source "$HOME/.config/shell/env.sh"' "$TARGET_BASHRC"
ensure_line '[ -f "$HOME/.config/shell/aliases.sh" ] && source "$HOME/.config/shell/aliases.sh"' "$TARGET_BASHRC"
ensure_line '[ -f "$HOME/.config/shell/starship-init.sh" ] && source "$HOME/.config/shell/starship-init.sh"' "$TARGET_BASHRC"

echo "[✓] shell hooks adicionados em $TARGET_BASHRC"
