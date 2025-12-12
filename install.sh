#!/bin/bash

set -e

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

FAILED_PACKAGES=()

echo "SENHA SUDO:"
sudo -v || exit 1
echo

############################################
# 1) DankMaterialShell
############################################
echo "[1/3] Instalando DankMaterialShell..."
if curl -fsSL https://install.danklinux.com | sh; then
    echo -e "${GREEN}DankMaterialShell instalado.${RESET}"
else
    echo -e "${RED}Falha no DankMaterialShell.${RESET}"
    FAILED_PACKAGES+=("DankMaterialShell")
fi
echo

############################################
# 2) GNOME-macOS-Tahoe
############################################
echo "[2/3] Clonando GNOME-macOS-Tahoe..."

rm -rf GNOME-macOS-Tahoe
if git clone https://github.com/kayozxo/GNOME-macOS-Tahoe.git; then
    cd GNOME-macOS-Tahoe
    chmod +x install
    if ./install; then
        echo -e "${GREEN}GNOME macOS Tahoe instalado.${RESET}"
    else
        echo -e "${RED}Erro no install do GNOME macOS Tahoe.${RESET}"
        FAILED_PACKAGES+=("macOS-Tahoe")
    fi
    cd ..
else
    echo -e "${RED}Não foi possível clonar GNOME-macOS-Tahoe.${RESET}"
    FAILED_PACKAGES+=("macOS-Tahoe")
fi
echo


############################################
# 3) Detectar AUR Helper
############################################
echo "[3/3] Verificando AUR helper..."

AUR_HELPER=""

if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
else
    echo "Nenhum AUR helper encontrado. Instalando yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    AUR_HELPER="yay"
fi

echo "AUR helper detectado: $AUR_HELPER"
echo


############################################
# 4) Listas de pacotes
############################################

PACMAN_PKGS=(
brightnessctl cliphist easyeffects firefox fuzzel gedit gnome-disks grim hyprland
mission-center nautilus nwg-look pavucontrol polkit polkit-gnome mate-polkit ptyxis qt6ct
slurp swappy tesseract wl-clipboard wlogout xdg-desktop-portal-hyprland yad
)

AUR_PKGS=(
botan2
brave-bin
dms-shell-bin
google-breakpad
grimblast-git
qt6ct-kde
quickshell-git
ttf-material-symbols-variable-git
wlogout
yay-git
)

############################################
# 5) Instalar pacotes Pacman
############################################
echo "Instalando pacotes pacman..."
for pkg in "${PACMAN_PKGS[@]}"; do
    if ! sudo pacman -S --needed --noconfirm "$pkg"; then
        echo -e "${RED}Falhou: $pkg${RESET}"
        FAILED_PACKAGES+=("$pkg")
    else
        echo -e "${GREEN}OK: $pkg${RESET}"
    fi
done
echo

############################################
# 6) Instalar pacotes AUR
############################################
echo "Instalando pacotes AUR..."
for pkg in "${AUR_PKGS[@]}"; do
    if ! $AUR_HELPER -S --needed --noconfirm "$pkg"; then
        echo -e "${RED}Falhou: $pkg${RESET}"
        FAILED_PACKAGES+=("$pkg")
    else
        echo -e "${GREEN}OK: $pkg${RESET}"
    fi
done
echo


############################################
# 7) Mover pastas para ~/.config
############################################
echo "Movendo hypr/ e DankMaterialShell/ para ~/.config..."

mkdir -p ~/.config

[ -d hypr ] && mv -f hypr ~/.config/
[ -d DankMaterialShell ] && mv -f DankMaterialShell ~/.config/

echo "Pastas movidas."
echo


############################################
# 8) Mostrar falhas
############################################
if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo -e "${RED}Pacotes que falharam:${RESET}"
    for p in "${FAILED_PACKAGES[@]}"; do
        echo -e "${RED}- $p${RESET}"
    done
else
    echo -e "${GREEN}Nenhuma falha encontrada.${RESET}"
fi

echo
echo "Finalizado. Reiniciando em 5 segundos..."
sleep 5
systemctl reboot
