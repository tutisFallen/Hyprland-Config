# Hyprland-Config (stack personalizada)

Stack atual:
- Niri / Hyprland (auto-detect no install)
- Kitty (tema glass/tahoe)
- Yazi
- Thunar
- Quickshell
- Ambxst
- Shell aliases + Starship + fzf + eza + nvim base
- GTK + Fontconfig (Matugen-friendly)

## Instalação

```bash
bash install.sh
```

Forçar compositor:

```bash
bash install.sh niri
bash install.sh hyprland
```

O script:
- instala pacotes base + fontes (Nerd/Emoji)
- detecta Niri/Hyprland automaticamente
- aplica só as configs do compositor ativo
- remove symlinks do compositor inativo

## Modo Bare Repo (opcional)

```bash
./scripts/bare-repo.sh init https://github.com/<user>/Hyprland-Config.git
./scripts/bare-repo.sh config status
```

Isso cria `~/.cfg` (bare) para gerenciar dotfiles direto do `$HOME`.

## Shell

O script adiciona source em `~/.bashrc` para:
- `~/.config/shell/env.sh`
- `~/.config/shell/aliases.sh`
- `~/.config/shell/starship-init.sh`
