#!/usr/bin/env bash
set -euo pipefail

# Apps = optional Flatpak app set

if ! command -v flatpak >/dev/null 2>&1; then
  echo "[apps][warn] flatpak not installed; skipping"
  exit 0
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

flatpak install -y flathub \
  be.alexandervanhee.gradia \
  com.brave.Browser \
  com.dec05eba.gpu_screen_recorder \
  com.spotify.Client \
  com.vscodium.codium \
  com.vysp3r.ProtonPlus \
  io.github.IshuSinghSE.aurynk \
  io.github.kolunmi.Bazaar \
  io.github.ltiber.Pwall \
  io.github.swordpuffin.wardrobe \
  org.prismlauncher.PrismLauncher || true

echo "[apps] Flatpak app set done ✅"
