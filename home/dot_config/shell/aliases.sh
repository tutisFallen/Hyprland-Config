# ---- pacman/yay ----
alias pss='sudo pacman -S --needed'
alias psi='sudo pacman -Syu'
alias psr='sudo pacman -Rns'
alias pqs='pacman -Qs'
alias pqi='pacman -Qi'

alias yss='yay -S --needed'
alias ysi='yay -Syu'
alias yrm='yay -Rns'
alias yqs='yay -Qs'

# ---- eza fallback ----
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=always --group-directories-first'
  alias ll='eza -lah --icons=always --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=always'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
fi

# ---- yazi/fzf/nvim ----
alias fm='yazi'
alias yz='yazi'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim .'
alias ff='fzf'
alias cdf='cd "$(find . -type d 2>/dev/null | fzf)"'

# ---- git ----
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'


# fzf -> nvim
alias vf='nvim "$(fzf)"'
alias vff='nvim $(fzf -m)'
alias fvim='nvim "$(fzf)"'
