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
export GREP_COLORS="fn=00;31:ln=00;33:mt=00;29"
alias grep="grep --color=always"

if command -v tatr &>/dev/null ; then
    output=$(tatr ls 2>/dev/null)
    count=$(echo "$output" | wc -l)
    if (( $count-1 > 0 )); then
        echo "There is a total of $count task(s) open:"
        printf "   %-17s    %-23s    %-20s\n" "Creation date" "Priority" "Task Title"
        while IFS= read -r line; do
            date=$(echo "$line" | awk -F'/' '{printf "%s", $3}')
            priority=$(echo "$line" | sed -e 's/.*\[.*: \(.*\) ,.*/\1/')
            title=$(echo "$line" | sed -e 's/.*\] \(.*\)/\1/')
            printf "  %-24s " "$date"
            printf '%3d' "$(($priority))" 2>/dev/null
            printf "%-14s %s\n" " " "$title"
        done <<< "$output"
        echo -e "\n-------------------------------------------------------------\n"
    fi
fi

