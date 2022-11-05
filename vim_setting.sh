#!/bin/bash

if [ -x /usr/bin/vim ]; then
    :
else
    if [ -x /usr/bin/apt ]; then
	sudo apt-get install vim
    elif [ -x /usr/bin/yum ]; then
	sudo yum -y install vim
    fi
fi

if [ -x /usr/bin/ctags ]; then
    :
else
    if [ -x /usr/bin/apt ]; then
	sudo apt-get install ctags
    elif [ -x /usr/bin/yum ]; then
	sudo yum -y install ctags
    fi
fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

cat > ~/.vimrc << "EOF"

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-airline/vim-airline'

Plugin 'scrooloose/nerdtree'

Plugin 'scrooloose/syntastic'

Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'baines/vim-colorscheme-thaumaturge' "color

Plugin 'morhetz/gruvbox' "color

Plugin 'taglist-plus'

call vundle#end()

filetype plugin indent on

let g:ctrlp_custom_ignore = {
            \ 'dir': '\.git$\|public$\|log$\|tmp$\|vendor$',
            \ 'file': '\v\.(exe|so|dll)$'
            \ }

let Tlist_Ctags_Cmd = "/usr/bin/ctags"

let Tlist_Inc_Winwidth = 0

let Tlist_Exit_OnlyWindow = 0

let Tlist_Auto_Open = 0

let Tlist_Use_Right_Window = 1



set ic
set nu
set softtabstop=4
set shiftwidth=4
set formatoptions=croql
set ruler
set showmode
set smartindent
set splitright "locate new vsplit window at right panel

"this makes backspace key work properly in gvim on Windows
"set backspace=2

"this makes Copy&Past(Ctrl + C, Ctrl + V) shortcut work properly on Windows
"set guioptions+=a
"set guifont=Fixedsys:h12

syntax on

color gruvbox
set background=dark

map ;t  <ESC>:NERDTreeToggle<CR>
map ;c <ESC>:TlistToggle<CR>
EOF

vim -c PluginInstall
