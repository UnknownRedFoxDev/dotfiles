export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

alias ls="$HOME/.cargo/bin/eza -l --icons --time-style=long-iso --group-directories-first"
alias ll='ls -la --icons --time-style=long-iso --group-directories-first'
alias fastfetch='/usr/bin/fastfetch -c ~/.config/fastfetch/test.jsonc'
alias ff='dir=$(find . -mindepth 1 -maxdepth 1 -type d | cut -c 3- | fzf) && [[ -n $dir ]] && cd $dir && clear'
alias change_wallpaper='quickshell ipc -p $HOME/opt/skwd-wall/daemon.qml call wallpaper toggle'

export EDITOR='nvim'
export XDG_CONFIG_HOME="$HOME/.config"
export PAGER='less'
export JAVA_HOME="/usr/lib/jvm/java-25-openjdk"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/opt/neovim/bin:$PATH"
