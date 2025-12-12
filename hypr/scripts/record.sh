#!/bin/bash

ICON="/home/michael/.config/hypr/scripts/screen.png"
ACTION="$1"

case "$ACTION" in
    start)
        if pgrep -f "gpu-screen-recorder" > /dev/null; then
            notify-send -a "Screen Recorder" -i "$ICON" "🎬 Gravação" "Já existe uma gravação em andamento!" -u normal
            exit 1
        fi
        mkdir -p ~/Videos
        gpu-screen-recorder -w portal -f 60 -a default_output -restore-portal-session yes -o ~/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4 &
        notify-send -a "Screen Recorder" -i "$ICON" "🔴 Gravando" "Captura de tela iniciada com sucesso!" -u normal
        ;;
    
    pause)
        if pgrep -f "gpu-screen-recorder" > /dev/null; then
            pkill -SIGUSR2 -f gpu-screen-recorder
            notify-send -a "Screen Recorder" -i "$ICON" "⏸️ Gravação" "Gravação pausada/retomada" -u normal
        else
            notify-send -a "Screen Recorder" -i "$ICON" "❌ Erro" "Nenhuma gravação ativa no momento!" -u critical
        fi
        ;;
    
    stop)
        if pgrep -f "gpu-screen-recorder" > /dev/null; then
            pkill -SIGINT -f gpu-screen-recorder
            notify-send -a "Screen Recorder" -i "$ICON" "✅ Concluído" "Vídeo salvo em ~/Videos com sucesso!" -u normal
        else
            notify-send -a "Screen Recorder" -i "$ICON" "❌ Erro" "Nenhuma gravação ativa para parar!" -u critical
        fi
        ;;
    
    *)
        echo "Uso: $0 {start|pause|stop}"
        exit 1
        ;;
esac
