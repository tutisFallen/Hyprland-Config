#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Dotfiles setup script (Arch Linux)
# Usage:
#   ./install.sh [auto|niri|hyprland] [--yes] [--no-flatpak] [--no-aur]
# -----------------------------------------------------------------------------

need_cmd() { command -v "$1" >/dev/null 2>&1; }

color() {
  local code="$1"; shift
  printf "\033[%sm%s\033[0m\n" "$code" "$*"
}

info()  { color "1;34" "[INFO] $*"; }
warn()  { color "1;33" "[WARN] $*"; }
error() { color "1;31" "[ERR ] $*"; }
ok()    { color "1;32" "[ OK ] $*"; }

ask_yes_no() {
  local prompt="$1" default_no="${2:-true}" reply
  if [[ "$ASSUME_YES" == "true" ]]; then
    return 0
  fi

  if [[ "$default_no" == "true" ]]; then
    read -r -p "$prompt [y/N] " reply
  else
    read -r -p "$prompt [Y/n] " reply
  fi

  reply="${reply,,}"
  if [[ -z "$reply" ]]; then
    [[ "$default_no" == "false" ]] && return 0 || return 1
  fi
  [[ "$reply" == "y" || "$reply" == "yes" ]]
}

ensure_internet() {
  info "Checking internet connectivity..."
  if need_cmd curl; then
    curl -fsS --max-time 8 https://archlinux.org >/dev/null
  elif need_cmd ping; then
    ping -c 1 -W 2 1.1.1.1 >/dev/null
  else
    warn "Neither curl nor ping available; skipping connectivity check."
    return 0
  fi
  ok "Internet connectivity: OK"
}

bootstrap_aur_helper() {
  if need_cmd yay; then
    AUR_HELPER="yay"
    return 0
  fi
  if need_cmd paru; then
    AUR_HELPER="paru"
    return 0
  fi

  warn "No AUR helper found (yay/paru)."
  if ! ask_yes_no "Bootstrap yay automatically?" true; then
    warn "Skipping AUR packages."
    ENABLE_AUR="false"
    return 0
  fi

  info "Installing prerequisites for yay..."
  sudo pacman -S --needed --noconfirm git base-devel

  local tmpdir
  tmpdir="$(mktemp -d)"
  info "Cloning yay into $tmpdir"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"

  if need_cmd yay; then
    AUR_HELPER="yay"
    ok "yay installed successfully"
  else
    error "Failed to install yay"
    ENABLE_AUR="false"
  fi
}

backup_conflict_path() {
  local target="$1"
  local rel
  rel="${target#"$HOME"/}"
  local dest="$BACKUP_DIR/$rel"

  mkdir -p "$(dirname "$dest")"
  mv "$target" "$dest"
  warn "Backed up conflict: $target -> $dest"
}

prepare_stow_conflicts_for_pkg() {
  local pkg="$1"
  local root="dotfiles/$pkg"
  [[ -d "$root" ]] || return 0

  while IFS= read -r -d '' src; do
    local rel target
    rel="${src#"$root"/}"
    target="$HOME/$rel"

    if [[ -e "$target" || -L "$target" ]]; then
      # If already a symlink into this repo, keep it.
      if [[ -L "$target" ]]; then
        local resolved
        resolved="$(readlink -f "$target" 2>/dev/null || true)"
        if [[ -n "$resolved" && "$resolved" == "$(readlink -f "$src")" ]]; then
          continue
        fi
      fi
      backup_conflict_path "$target"
    fi
  done < <(find "$root" -type f -print0)
}

prepare_stow_conflicts() {
  info "Checking for dotfile conflicts before stow..."
  mkdir -p "$BACKUP_DIR"
  local pkg
  for pkg in "$@"; do
    prepare_stow_conflicts_for_pkg "$pkg"
  done
  ok "Conflict check complete"
}

install_pacman_packages() {
  if ! need_cmd stow; then
    info "Installing stow..."
    sudo pacman -S --needed --noconfirm stow
  fi

  info "Installing base/font/theme/WM packages via pacman"
  sudo pacman -S --needed --noconfirm \
    "${BASE_PKGS[@]}" "${FONT_PKGS[@]}" "${THEME_PKGS[@]}" "${WM_PKGS[@]}"
  ok "Pacman packages installed"
}

install_aur_packages() {
  [[ "$ENABLE_AUR" == "true" ]] || { warn "AUR install disabled"; return 0; }
  bootstrap_aur_helper
  [[ "$ENABLE_AUR" == "true" ]] || return 0

  info "Installing AUR packages via $AUR_HELPER"
  "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"
  ok "AUR packages installed"
}

install_flatpaks() {
  [[ "$ENABLE_FLATPAK" == "true" ]] || { warn "Flatpak install disabled"; return 0; }

  if ! need_cmd flatpak; then
    warn "flatpak command not found after pacman install"
    return 0
  fi

  info "Adding flathub remote (if needed)"
  if ! flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
    warn "Failed to add flathub remote"
  fi

  local failed=0 app
  for app in "${FLATPAK_APPS[@]}"; do
    if ! flatpak install -y flathub "$app"; then
      warn "Flatpak failed: $app"
      failed=$((failed + 1))
    fi
  done

  if (( failed > 0 )); then
    warn "Flatpak install finished with $failed failures"
  else
    ok "Flatpak apps installed"
  fi
}

apply_dotfiles() {
  local all_stow=("${COMMON_STOW[@]}" "${WM_STOW[@]}")

  prepare_stow_conflicts "${all_stow[@]}"

  info "Applying common dotfiles: ${COMMON_STOW[*]}"
  stow -v -R -d dotfiles -t "$HOME" "${COMMON_STOW[@]}"

  info "Applying compositor dotfiles: ${WM_STOW[*]}"
  stow -v -R -d dotfiles -t "$HOME" "${WM_STOW[@]}"

  info "Removing inactive compositor dotfiles: ${WM_REMOVE[*]}"
  local pkg
  for pkg in "${WM_REMOVE[@]}"; do
    stow -v -D -d dotfiles -t "$HOME" "$pkg" || true
  done

  ok "Dotfiles applied"
}

# ------------------------------- args -----------------------------------------
COMPOSITOR="auto"
ASSUME_YES="false"
ENABLE_FLATPAK="true"
ENABLE_AUR="true"
AUR_HELPER=""

for arg in "$@"; do
  case "$arg" in
    auto|niri|hyprland) COMPOSITOR="$arg" ;;
    --yes|-y) ASSUME_YES="true" ;;
    --no-flatpak) ENABLE_FLATPAK="false" ;;
    --no-aur) ENABLE_AUR="false" ;;
    *)
      error "Unknown argument: $arg"
      echo "Usage: $0 [auto|niri|hyprland] [--yes] [--no-flatpak] [--no-aur]"
      exit 1
      ;;
  esac
done

# ------------------------------ data ------------------------------------------
BASE_PKGS=(kitty yazi thunar fzf eza neovim starship rsync mpv playerctl socat flatpak python-gobject python-imageio python-imageio-ffmpeg python-screeninfo python-platformdirs nwg-look)
FONT_PKGS=(ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts noto-fonts-emoji noto-fonts-cjk otf-font-awesome)
THEME_PKGS=(adwaita-icon-theme papirus-icon-theme arc-gtk-theme materia-gtk-theme)
AUR_PKGS=(waypaper mpvpaper catppuccin-gtk-theme-mocha whitesur-gtk-theme)

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

if [[ "$COMPOSITOR" == "niri" ]]; then
  WM_PKGS=(niri waybar xdg-desktop-portal-gnome xdg-desktop-portal-gtk)
  WM_STOW=(niri)
  WM_REMOVE=(hypr)
else
  WM_PKGS=(hyprland hypridle hyprlock waybar xdg-desktop-portal-hyprland)
  WM_STOW=(hypr)
  WM_REMOVE=(niri)
fi

COMMON_STOW=(kitty nvim quickshell shell starship thunar yazi gtk fontconfig waypaper localbin)

FLATPAK_APPS=(
  be.alexandervanhee.gradia
  com.brave.Browser
  com.dec05eba.gpu_screen_recorder
  com.spotify.Client
  com.vscodium.codium
  com.vysp3r.ProtonPlus
  io.github.IshuSinghSE.aurynk
  io.github.kolunmi.Bazaar
  io.github.ltiber.Pwall
  io.github.swordpuffin.wardrobe
  org.prismlauncher.PrismLauncher
)

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# ------------------------------ run -------------------------------------------
info "Compositor target: $COMPOSITOR"
[[ "$ENABLE_AUR" == "true" ]] && info "AUR packages: enabled" || info "AUR packages: disabled"
[[ "$ENABLE_FLATPAK" == "true" ]] && info "Flatpaks: enabled" || info "Flatpaks: disabled"

ensure_internet
install_pacman_packages

if [[ "$ENABLE_AUR" == "true" ]] && ask_yes_no "Install AUR package set?" true; then
  install_aur_packages
fi

if [[ "$ENABLE_FLATPAK" == "true" ]] && ask_yes_no "Install Flatpak app set?" true; then
  install_flatpaks
fi

apply_dotfiles

info "Running shell setup"
bash ./setup-shell.sh

info "Refreshing font cache"
if ! fc-cache -fv >/dev/null; then
  warn "fc-cache reported warnings"
fi

ok "Setup complete. Open a new terminal/session."
info "If files were moved, backups are in: $BACKUP_DIR"