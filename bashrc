# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias sudovim='sudo -E -s nvim'
PS1='[\u@\h \W]\$ '
export PATH="$PATH:$HOME/dotfiles/scripts"
