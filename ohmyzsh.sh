#!/bin/sh

if [ ! -n "$ZSH" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    sed -i '/^plugins=/c plugins=(\n\t git\n\t copypath\n\t cp\n\t dircycle\n\t dirpersist\n\t vi-mode\n\t autoenv\n\t autojump\n\t bgnotify\n\t copybuffer\n\t)' ~/.zshrc

    cat << EOF >> ~/.zshrc

source .zshrc_my
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# alt + arrow
bindkey '^[[1;3D' insert-cycledleft
bindkey '^[[1;3C' insert-cycledright
bindkey '^[[1;3A' insert-cycledup
bindkey '^[[1;3B' insert-cycleddown

source '/usr/share/autoenv-git/activate.sh'
source $HOME/.zsh-background-notify/bgnotify.plugin.zsh
EOF

fi

if [ ! -d "/usr/share/autoenv-git" ]; then
    yay -S --noconfirm autoenv-git
fi

if [ ! -f "/usr/bin/autojump" ]; then
    yay -S --noconfirm autojump-rs
fi

# setting bgnotify
if [ ! -d "$HOME/.zsh-background-notify" ]; then
    git clone https://github.com/t413/zsh-background-notify.git ~/.zsh-background-notify

    # patch for wayland and sway
    sed -i '/^currentWindowId () {/,/^}$/c\
currentWindowId () {\
    echo $(swaymsg -t get_tree | jq -r ".. | select(.focused?) | .id")\
}
' ~/.zsh-background-notify/bgnotify.plugin.zsh
fi
