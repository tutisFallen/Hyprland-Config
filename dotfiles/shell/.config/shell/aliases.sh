# package helpers
alias pss='sudo pacman -S --needed'
alias psi='sudo pacman -Syu'
alias psr='sudo pacman -Rns'
alias psc='sudo pacman -Sc'
alias psscc='sudo pacman -Scc'
alias pqs='pacman -Qs'
alias pqi='pacman -Qi'

alias yss='yay -S --needed'
alias ysi='yay -Syu'
alias yrm='yay -Rns'
alias ycc='yay -Sc'
alias yqq='yay -Qs'

# modern ls stack
alias ls='eza --icons=always --group-directories-first'
alias ll='eza -lah --icons=always --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=always'
alias la='eza -la --icons=always --group-directories-first'

# yazi/fzf/nav
alias fm='yazi'
alias yz='yazi'
alias fzfp='fzf --preview "bat --style=numbers --color=always {}"'
alias cdf='cd "$(find . -type d | fzf)"'

# nvim quality of life
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim .'

# git quick
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
