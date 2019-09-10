#!/bin/bash

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

cat >> ~/.vimrc << EOF

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

call vundle#end()

filetype plugin indent on

let g:ctrlp_custom_ignore = {
            \ 'dir': '\.git$\|public$\|log$\|tmp$\|vendor$',
            \ 'file': '\v\.(exe|so|dll)$'
            \ }


set ic
set nu
set softtabstop=4
set shiftwidth=4
set formatoptions=croql
set ruler
set showmode
set smartindent

"this makes backspace key work properly in gvim on Windows
"set backspace=2

"this makes Copy&Past(Ctrl + C, Ctrl + V) shortcut work properly on Windows
"set guioptions+=a
"set guifont=Fixedsys:h12

syntax on

color gruvbox
set background=dark

map <Leader>nt <ESC>:NERDTree<CR>
map <Leader>n  <ESC>:NERDTreeToggle<CR>
EOF

vim -c PluginInstall

