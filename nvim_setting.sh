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

set background=dark

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox' "color
Plug 'baines/vim-colorscheme-thaumaturge' "color
Plug 'preservim/nerdtree' 
Plug 'vim-airline/vim-airline'

" -- python plugin start --
Plug 'Shougo/ddc.vim'
Plug 'vim-denops/denops.vim'
Plug 'Shougo/ddc-matcher_head'
Plug 'Shougo/ddc-sorter_rank'
Plug 'Shougo/ddc-ui-native'
Plug 'Shougo/ddc-source-around'
" -- python plugin end --

call plug#end()


" Customize global settings

" You must set the default ui.
" NOTE: native ui
" https://github.com/Shougo/ddc-ui-native
call ddc#custom#patch_global('ui', 'native')

" Use around source.
" https://github.com/Shougo/ddc-source-around
call ddc#custom#patch_global('sources', ['around'])

" Use matcher_head and sorter_rank.
" https://github.com/Shougo/ddc-matcher_head
" https://github.com/Shougo/ddc-sorter_rank
call ddc#custom#patch_global('sourceOptions', #{
      \ _: #{
      \   matchers: ['matcher_head'],
      \   sorters: ['sorter_rank']},
      \ })

" Change source options
call ddc#custom#patch_global('sourceOptions', #{
      \   around: #{ mark: 'A' },
      \ })
call ddc#custom#patch_global('sourceParams', #{
      \   around: #{ maxSize: 500 },
      \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype(['c', 'cpp'], 'sources',
      \ ['around', 'clangd'])
call ddc#custom#patch_filetype(['c', 'cpp'], 'sourceOptions', #{
      \   clangd: #{ mark: 'C' },
      \ })
call ddc#custom#patch_filetype('markdown', 'sourceParams', #{
      \   around: #{ maxSize: 100 },
      \ })

" Mappings

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

" Use ddc.
call ddc#enable()


" key map

map <leader>t <ESC>:NERDTreeToggle<CR>

EOF

nvim -c PlugInstall
