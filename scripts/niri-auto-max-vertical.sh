#!/usr/bin/env bash
set -euo pipefail

TARGET_OUTPUT="${NIRI_TARGET_OUTPUT:-DP-1}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/niri-auto-max"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-auto-max-vertical.lock"
PROCESSED_FILE="$STATE_DIR/processed_windows"

mkdir -p "$STATE_DIR"
touch "$PROCESSED_FILE"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "[niri-auto-max] jq não encontrado. Instale jq para usar este script." >&2
  exit 1
fi

window_seen() {
  local wid="$1"
  grep -qx "$wid" "$PROCESSED_FILE" 2>/dev/null
}

mark_window() {
  local wid="$1"
  echo "$wid" >> "$PROCESSED_FILE"
}

cleanup_state() {
  # Remove IDs que não existem mais.
  local live
  live="$(niri msg -j windows 2>/dev/null | jq -r '.[].id' || true)"
  if [[ -z "$live" ]]; then
    : > "$PROCESSED_FILE"
    return
  fi
  awk 'NR==FNR{a[$1]=1;next} a[$1]' <(printf "%s\n" "$live" | sort -u) <(sort -u "$PROCESSED_FILE") > "$PROCESSED_FILE.tmp" || true
  mv "$PROCESSED_FILE.tmp" "$PROCESSED_FILE"
}

focused_window_id() {
  niri msg -j focused-window 2>/dev/null | jq -r '.id // empty' || true
}

focused_window_output() {
  local wid="$1"
  niri msg -j windows 2>/dev/null | jq -r --argjson wid "$wid" '.[] | select(.id == $wid) | .workspace_id' | {
    read -r wsid || true
    [[ -n "${wsid:-}" ]] || { echo ""; return; }
    niri msg -j workspaces 2>/dev/null | jq -r --argjson ws "$wsid" '.[] | select(.id == $ws) | .output // empty'
  }
}

apply_maximize_if_needed() {
  local wid out
  wid="$(focused_window_id)"
  [[ -n "$wid" ]] || return 0

  window_seen "$wid" && return 0

  out="$(focused_window_output "$wid")"
  [[ "$out" == "$TARGET_OUTPUT" ]] || return 0

  # Mesmo comportamento do SUPER+F (maximize-column).
  niri msg action maximize-column >/dev/null 2>&1 || true
  mark_window "$wid"
}

cleanup_state

niri msg -j event-stream | while IFS= read -r _; do
  apply_maximize_if_needed
  cleanup_state
done
