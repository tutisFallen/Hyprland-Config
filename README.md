# Hyprland-Config (stack personalizada)

Stack atual:
- Hyprland
- Kitty (tema glass/tahoe)
- Yazi
- Thunar
- Quickshell
- Ambxst
- Shell aliases + Starship + fzf + eza + nvim base

## Instalação

```bash
bash install.sh
```

## Aliases úteis

- Pacman: `pss`, `psi`, `psr`, `pqs`
- Yay: `yss`, `ysi`, `yrm`, `yqq`
- Navegação: `fm` (yazi), `cdf` (cd + fzf)
- Listing: `ls`, `ll`, `lt` com `eza --icons`
- Neovim: `v`, `vi`, `vim`, `nv`

## Shell

O script adiciona source em `~/.bashrc` para:
- `~/.config/shell/env.sh`
- `~/.config/shell/aliases.sh`
- `~/.config/shell/starship-init.sh`
