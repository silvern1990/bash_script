#!/bin/bash

if [ -x /usr/bin/nvim ] || [ -x /snap/bin/nvim ]; then
    :
else
    if [ -x /usr/bin/apt ]; then
		sudo apt install nvim
	elif [ -x /usr/bin/dnf ]; then
		sudo dnf install ripgrep
    elif [ -x /usr/bin/yum ]; then
		sudo yum -y install nvim
    fi
fi

if [ -x /usr/bin/ripgrep ]; then
	:
else
	if [ -x /usr/bin/apt ]; then
		sudo apt install ripgrep
	elif [ -x /usr/bin/dnf ]; then
		sudo dnf install ripgrep
	elif [ -x /usr/bin/yum ]; then
		sudo yum -y install ripgrep
	fi
fi


mv ~/.config/nvim ~/.config/nvim.bak

mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

mkdir -p ~/.config/nvim/lua/user

git clone https://github.com/silvern1990/astronvim_for_spring ~/.config/nvim/lua/user

cd ~/.config/nvim/lua/user
git pull origin mine
