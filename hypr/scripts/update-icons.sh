#!/bin/bash

# Aguardar o sistema inicializar
sleep 3

# Atualizar caches de ícones
gtk-update-icon-cache -f -t /var/lib/flatpak/exports/share/icons/hicolor 2>/dev/null
gtk-update-icon-cache -f -t ~/.local/share/flatpak/exports/share/icons/hicolor 2>/dev/null
gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null
gtk-update-icon-cache -f -t /usr/share/icons/Papirus-Dark 2>/dev/null

# Atualizar database de aplicativos
update-desktop-database /var/lib/flatpak/exports/share/applications 2>/dev/null
update-desktop-database ~/.local/share/applications 2>/dev/null

# Regenerar cache do pixbuf (para SVGs)
gdk-pixbuf-query-loaders --update-cache 2>/dev/null

# Limpar cache antigo do DMS (se existir)
rm -rf ~/.cache/dms/icon-cache 2>/dev/null

exit 0
