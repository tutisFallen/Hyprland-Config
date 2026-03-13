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

install_python_extras_for_pacman() {
  [[ "$PKG_MANAGER" == "pacman" ]] || return 0

  # Arch usa PEP 668 (externally-managed), então evitamos pip global/--user.
  # Criamos um venv dedicado para extras não empacotados no pacman.
  if ! need_cmd python; then
    warn "python not available; skipping Python extras venv"
    return 0
  fi

  local venv_dir="${XDG_DATA_HOME:-$HOME/.local/share}/hyprland-config/py-venv"
  local pip_pkgs=(imageio-ffmpeg screeninfo)

  if [[ ! -x "$venv_dir/bin/python" ]]; then
    log "Creating Python venv for extras: $venv_dir"
    python -m venv "$venv_dir"
  fi

  log "Installing Python extras in venv: ${pip_pkgs[*]}"
  "$venv_dir/bin/python" -m pip install --upgrade pip
  "$venv_dir/bin/python" -m pip install --upgrade "${pip_pkgs[@]}"

  log "Python extras installed in venv. Use: $venv_dir/bin/python"
}

choose_aur_helper() {
  # If only one helper exists, use it automatically.
  if need_cmd paru && ! need_cmd yay; then
    AUR_HELPER="paru"
    return 0
  fi
  if need_cmd yay && ! need_cmd paru; then
    AUR_HELPER="yay"
    return 0
  fi

  # If both exist, ask which one to use.
  if need_cmd paru && need_cmd yay; then
    local choice=""
    if [[ -t 0 ]]; then
      read -r -p "[pkg] Detectei paru e yay. Qual você quer usar para instalar do AUR? [paru/yay] (padrão: paru): " choice
    fi
    choice="${choice,,}"
    case "$choice" in
      yay) AUR_HELPER="yay" ;;
      ""|paru) AUR_HELPER="paru" ;;
      *)
        warn "Escolha inválida ('$choice'). Vou usar paru por padrão."
        AUR_HELPER="paru"
        ;;
    esac
    return 0
  fi

  # None installed: ask which one to bootstrap.
  local bootstrap_choice=""
  if [[ -t 0 ]]; then
    read -r -p "[pkg] Não encontrei helper AUR. Quer instalar qual? [paru/yay] (padrão: paru): " bootstrap_choice
  fi
  bootstrap_choice="${bootstrap_choice,,}"
  case "$bootstrap_choice" in
    yay) AUR_HELPER="yay" ;;
    ""|paru) AUR_HELPER="paru" ;;
    *)
      warn "Escolha inválida ('$bootstrap_choice'). Vou instalar paru por padrão."
      AUR_HELPER="paru"
      ;;
  esac
}

bootstrap_aur_helper_if_needed() {
  need_cmd "$AUR_HELPER" && return 0

  log "Instalando pré-requisitos para AUR helper: base-devel git"
  sudo pacman -S --needed --noconfirm base-devel git

  local repo tmpdir pkgdir
  case "$AUR_HELPER" in
    paru) repo="https://aur.archlinux.org/paru-bin.git" ;;
    yay)  repo="https://aur.archlinux.org/yay-bin.git" ;;
    *)
      warn "AUR helper inválido: $AUR_HELPER"
      return 1
      ;;
  esac

  tmpdir="$(mktemp -d)"
  pkgdir="$tmpdir/${AUR_HELPER}-bin"

  log "Baixando e instalando $AUR_HELPER via AUR"
  git clone --depth 1 "$repo" "$pkgdir"
  (
    cd "$pkgdir"
    makepkg -si --noconfirm
  )
}

install_aur() {
  [[ "$PKG_MANAGER" == "pacman" ]] || return 0
  [[ "$INSTALL_AUR" == "true" ]] || { warn "AUR install disabled"; return 0; }

  choose_aur_helper
  bootstrap_aur_helper_if_needed || { warn "Falha ao preparar helper AUR ($AUR_HELPER), pulando AUR"; return 0; }

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
  install_python_extras_for_pacman

  log "Package installation complete"
}

main "$@"
