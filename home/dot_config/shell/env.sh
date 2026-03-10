export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='kitty'

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi
export FZF_DEFAULT_OPTS='--height 45% --layout=reverse --border --color=bg+:#313244,bg:#11111b,fg:#cdd6f4,header:#89b4fa,hl:#89b4fa,pointer:#f38ba8,marker:#f9e2af,prompt:#a6e3a1'

if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always {}"'
else
  export FZF_CTRL_T_OPTS='--preview "sed -n 1,200p {}"'
fi
