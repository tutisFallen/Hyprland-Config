# Hyprland Dotfiles

Configuração base para Arch + Hyprland, feita para setup rápido de um sistema novo.

## Estrutura

- `dotfiles/hypr` → Hyprland, hypridle, hyprlock
- `dotfiles/waybar` → barra
- `dotfiles/kitty` → terminal
- `dotfiles/wofi` → launcher
- `dotfiles/swaync` → notificações

## Instalação rápida

```bash
sudo pacman -S --needed hyprland waybar wofi kitty swaync hypridle hyprlock wl-clipboard grim slurp
bash install.sh
```

## Aplicar configs

```bash
stow dotfiles
```
