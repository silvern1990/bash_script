#!/bin/bash

if [ -x /usr/bin/vim ]; then
    :
else
    if [ -x /usr/bin/apt ]; then
	sudo apt-get install nvim
    elif [ -x /usr/bin/yum ]; then
	sudo yum -y install nvim
    fi
fi

if [ -x /usr/bin/ctags ]; then
    :
else
    if [ -x /usr/bin/apt ]; then
	sudo apt-get install ctags
    elif [ -x /usr/bin/yum ]; then
	sudo yum -y install ctags
    elif [ -x /usr/bin/pacman ]; then
	sudo pacman -S ctags
    fi
fi

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


if [ -d ~/.config/nvim ]; then
    :
else
    mkdir -p ~/.config/nvim

fi

cat > ~/.config/nvim/init.vim << "EOF"


call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox' "color
Plug 'baines/vim-colorscheme-thaumaturge' "color
Plug 'preservim/nerdtree' 
Plug 'vim-airline/vim-airline'

call plug#end()

set ic
set nu
set softtabstop=4
set shiftwidth=4
set formatoptions=croql
set ruler
set showmode
set smartindent
set splitright "locate new vsplit window at right panel
set clipboard+=unnamedplus

"this makes backspace key work properly in gvim on Windows
"set backspace=2

"this makes Copy&Past(Ctrl + C, Ctrl + V) shortcut work properly on Windows
"set guioptions+=a
"set guifont=Fixedsys:h12

syntax on

color gruvbox
set background=dark

map ;n <ESC>:NERDTreeToggle<CR>
map ;t <ESC>:TlistToggle<CR>

EOF

nvim -c PlugInstall
