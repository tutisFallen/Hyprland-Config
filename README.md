# Hyprland-Config (stack personalizada)

Stack atual:
- Niri / Hyprland (auto-detect no install)
- Kitty (tema glass/tahoe)
- Yazi
- Thunar
- Quickshell
- Shell aliases + Starship + fzf + eza + nvim base
- GTK + Fontconfig (Matugen-friendly)
- Waypaper + mpvpaper (video/gif wallpaper)
- nwg-look + temas GTK (Catppuccin/WhiteSur) + ícones Papirus

## Screenshots

![Screenshot 1](assets/screenshots/screenshot-2026-03-04-20-16-23.png)
![Screenshot 2](assets/screenshots/screenshot-2026-03-04-20-16-35.png)

## Instalação (Chezmoi + multi-distro)

```bash
bash install.sh
```

Forçar compositor:

```bash
bash install.sh niri
bash install.sh hyprland
```

Flags úteis:

```bash
bash install.sh --yes
bash install.sh --no-flatpak
bash install.sh --no-aur
```

O script agora:
- detecta distro (`pacman`, `dnf`, `apt`, `zypper`, `xbps`) e instala pacotes via `scripts/install-packages.sh`
- usa mapeamento agnóstico por grupo em `scripts/pkg-map.sh`
- instala `chezmoi` e aplica dotfiles da pasta `home/`
- detecta Niri/Hyprland automaticamente (ou força por argumento)
- separa fluxo em:
  - `scripts/install-core.sh` (base + chezmoi + shell/fonts)
  - `scripts/install-apps.sh` (Flatpak app set)
- mantém instalação opcional de Flatpaks
- em Arch, instala stack AUR quando helper (`yay/paru`) estiver disponível
- no Arch, inclui extras desktop (quickshell, fuzzel, cliphist, matugen etc.) e fontes adicionais (Inter/Fira Code)
- no AUR (Arch), inclui também: `anyrun`, `dgop`, `python-pynvml`, `wlogout`, `ttf-material-symbols-variable-git`
- fontes por download opcional: `bash scripts/install-fonts.sh` (Inter Variable + Fira Code)

Atalhos (Niri):
- `Mod+Shift+W` abre o Waypaper (backend mpvpaper)
- ao iniciar sessão: `waypaper --restore`

## Modo Bare Repo (opcional)

```bash
./scripts/bare-repo.sh init https://github.com/<user>/Hyprland-Config.git
./scripts/bare-repo.sh config status
```

Isso cria `~/.cfg` (bare) para gerenciar dotfiles direto do `$HOME`.

## Flatpaks padrão

O `install.sh` também garante Flathub e instala:

- be.alexandervanhee.gradia
- com.brave.Browser
- com.dec05eba.gpu_screen_recorder
- com.spotify.Client
- com.vscodium.codium
- com.vysp3r.ProtonPlus
- io.github.IshuSinghSE.aurynk
- io.github.kolunmi.Bazaar
- io.github.ltiber.Pwall
- io.github.swordpuffin.wardrobe
- org.prismlauncher.PrismLauncher

Comando equivalente manual:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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
  org.prismlauncher.PrismLauncher
```

## Shell

O script adiciona source em `~/.bashrc` para:
- `~/.config/shell/env.sh`
- `~/.config/shell/aliases.sh`
- `~/.config/shell/starship-init.sh`
