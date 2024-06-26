#!/bin/bash

OS=$(uname -s)


if [ $OS == 'Linux' ]; then

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

elif [ $OS == 'Darwin' ]; then

	if ! type brew &> /dev/null; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	if ! type java &> /dev/null; then
		brew install openjdk@17
	fi

	if ! type nvim &> /dev/null; then
		brew install nvim
	fi

	if ! type ripgrep &> /dev/null; then
		brew install ripgrep
		ln -s $(which /opt/homebrew/Cellar/ripgrep/*/bin/rg) /opt/homebrew/bin/ripgrep
	fi
fi



mv ~/.config/nvim ~/.config/nvim.bak

mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

git clone --depth 1 --branch v3.45.3 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

mkdir -p ~/.config/nvim/lua/user

git clone https://github.com/silvern1990/astronvim_for_spring ~/.config/nvim/lua/user

cd ~/.config/nvim/lua/user
git pull origin mine

git clone https://github.com/microsoft/java-debug ~/.local/share/nvim/java-debug

cd ~/.local/share/nvim/java-debug

./mvnw clean install

git clone https://github.com/microsoft/vscode-java-test ~/.local/share/nvim/java-debug/vscode-java-test

cd ~/.local/share/nvim/java-debug/vscode-java-test

npm install

npm run build-plugin



