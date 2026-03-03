#!/usr/bin/env bash
set -euo pipefail

# Bare repo dotfiles manager
# Usage:
#   ./scripts/bare-repo.sh init https://github.com/<user>/Hyprland-Config.git
#   ./scripts/bare-repo.sh config status
#   ./scripts/bare-repo.sh config add ~/.config/niri/config.kdl
#   ./scripts/bare-repo.sh config commit -m "update"
#   ./scripts/bare-repo.sh config push

CFG_DIR="$HOME/.cfg"

cfg() {
  git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"
}

cmd="${1:-}"
case "$cmd" in
  init)
    remote="${2:-}"
    if [[ -z "$remote" ]]; then
      echo "Usage: $0 init <git-remote-url>"
      exit 1
    fi
    [[ -d "$CFG_DIR" ]] || git clone --bare "$remote" "$CFG_DIR"
    cfg config --local status.showUntrackedFiles no
    echo "alias config='git --git-dir=$HOME/.cfg --work-tree=$HOME'"
    echo "Run: config checkout"
    ;;
  config)
    shift
    cfg "$@"
    ;;
  *)
    echo "Usage: $0 {init <remote>|config <git-args...>}"
    exit 1
    ;;
esac
