# cria pastas XDG se não existirem
for d in Desktop Documents Music Pictures Videos Downloads; do
    [ -d "$HOME/$d" ] || mkdir -p "$HOME/$d"
done

xdg-user-dirs-update

