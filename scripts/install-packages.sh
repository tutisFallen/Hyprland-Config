#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/pkg-map.sh"

need_cmd() { command -v "$1" >/dev/null 2>&1; }

log() { printf '[pkg] %s\n' "$*"; }
warn() { printf '[pkg][warn] %s\n' "$*" >&2; }

PKG_MANAGER=""
PKG_INSTALL_CMD=""
AUR_HELPER=""

COMPOSITOR="${1:-auto}"  # auto|niri|hyprland
INSTALL_AUR="${INSTALL_AUR:-true}"

if [[ "$COMPOSITOR" == "auto" ]]; then
  env_lc="${XDG_CURRENT_DESKTOP:-} ${DESKTOP_SESSION:-}"
  env_lc="${env_lc,,}"
  if [[ "$env_lc" == *"niri"* ]]; then
    COMPOSITOR="niri"
  elif [[ "$env_lc" == *"hypr"* ]]; then
    COMPOSITOR="hyprland"
  elif need_cmd niri; then
    COMPOSITOR="niri"
  else
    COMPOSITOR="hyprland"
  fi
fi

detect_pkg_manager() {
  if need_cmd pacman; then
    PKG_MANAGER="pacman"
    PKG_INSTALL_CMD="sudo pacman -S --needed --noconfirm"
  elif need_cmd dnf; then
    PKG_MANAGER="dnf"
    PKG_INSTALL_CMD="sudo dnf install -y"
  elif need_cmd apt-get; then
    PKG_MANAGER="apt"
    PKG_INSTALL_CMD="sudo apt-get install -y"
    sudo apt-get update -y
  elif need_cmd zypper; then
    PKG_MANAGER="zypper"
    PKG_INSTALL_CMD="sudo zypper --non-interactive install"
  elif need_cmd xbps-install; then
    PKG_MANAGER="xbps"
    PKG_INSTALL_CMD="sudo xbps-install -Sy"
  else
    echo "No supported package manager found (pacman/dnf/apt/zypper/xbps)" >&2
    exit 1
  fi
}

pkgs_for() {
  local group="$1"
  case "$PKG_MANAGER" in
    pacman) echo "${PKG_MAP_PACMAN[$group]:-}" ;;
    dnf)    echo "${PKG_MAP_DNF[$group]:-}" ;;
    apt)    echo "${PKG_MAP_APT[$group]:-}" ;;
    zypper) echo "${PKG_MAP_ZYPPER[$group]:-}" ;;
    xbps)   echo "${PKG_MAP_XBPS[$group]:-}" ;;
  esac
}

install_group() {
  local group="$1"; shift || true
  local p
  p="$(pkgs_for "$group")"
  [[ -n "$p" ]] || { warn "Group '$group' is unavailable or not mapped for '$PKG_MANAGER'; skipping."; return 0; }
  log "Installing [$group]: $p"
  # shellcheck disable=SC2086
  eval "$PKG_INSTALL_CMD $p"
}

ensure_chezmoi() {
  if need_cmd chezmoi; then
    return 0
  fi

  log "Installing chezmoi"
  case "$PKG_MANAGER" in
    pacman) sudo pacman -S --needed --noconfirm chezmoi ;;
    dnf)    sudo dnf install -y chezmoi ;;
    zypper) sudo zypper --non-interactive install chezmoi ;;
    xbps)   sudo xbps-install -Sy chezmoi ;;
    apt)
      if ! sudo apt-get install -y chezmoi; then
        warn "chezmoi package unavailable on apt, using official installer"
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
      fi
      ;;
  esac
}

install_aur() {
  [[ "$PKG_MANAGER" == "pacman" ]] || return 0
  [[ "$INSTALL_AUR" == "true" ]] || { warn "AUR install disabled"; return 0; }

  if need_cmd yay; then
    AUR_HELPER="yay"
  elif need_cmd paru; then
    AUR_HELPER="paru"
  else
    warn "No AUR helper found (yay/paru), skipping AUR packages"
    return 0
  fi

  local aur_pkgs="waypaper mpvpaper catppuccin-gtk-theme-mocha whitesur-gtk-theme anyrun dgop python-pynvml wlogout ttf-material-symbols-variable-git"
  log "Installing AUR packages via $AUR_HELPER: $aur_pkgs"
  # shellcheck disable=SC2086
  "$AUR_HELPER" -S --needed --noconfirm $aur_pkgs
}

main() {
  detect_pkg_manager
  log "Detected package manager: $PKG_MANAGER"
  log "Compositor target: $COMPOSITOR"

  install_group core
  install_group cli
  install_group desktop
  install_group python
  install_group fonts
  install_group themes
  install_group "$COMPOSITOR"

  ensure_chezmoi
  install_aur

  log "Package installation complete"
}

main "$@"
