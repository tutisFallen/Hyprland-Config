#!/bin/bash

# Monitorar mudanças nos apps Flatpak
inotifywait -m -e create,delete /var/lib/flatpak/exports/share/applications/ |
while read path action file; do
    echo "App instalado/removido: $file"
    sleep 2
    ~/.config/hypr/scripts/update-icons.sh
    pkill dms && dms run &
done
