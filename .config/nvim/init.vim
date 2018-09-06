set nocompatible " Forget about old, embrace new!


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NVIM Plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin(expand('~/.config/nvim/plugged'))
"Plug 'scrooloose/nerdtree'
"Plug 'xuyuanp/nerdtree-git-plugin'
"Plug 'tpope/vim-commentary'
"Plug 'tpope/vim-fugitive'
Plug 'dracula/vim'
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Plug 'airblade/vim-gitgutter'
"Plug 'vim-scripts/grep.vim'
"Plug 'vim-scripts/CSApprox'
"Plug 'bronson/vim-trailing-whitespace'
"Plug 'Raimondi/delimitMate'
"Plug 'majutsushi/tagbar'
"Plug 'scrooloose/syntastic'
"Plug 'Yggdroot/indentLine'
"Plug 'avelino/vim-bootstrap-updater'
call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDtree config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:NERDTreeChDirMode=2
"let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
"let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
"let g:NERDTreeShowBookmarks=1
"let g:nerdtree_tabs_focus_on_files=1
"let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
"let g:NERDTreeWinSize = 50
"set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
"nnoremap <silent> <F2> :NERDTreeFind<CR>
"noremap <F3> :NERDTreeToggle<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sensible default config to make life easier
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" UI improvments
set hidden
set number                   " show line number
set showcmd                  " show command in bottom bar
set cursorline               " highlight current line
set showmatch                " highlight matching brace
set laststatus=2             " window will always have a status line
syntax on                    " enable syntax coloring
set textwidth=80             " 80-chars line wrapping (activate with v ... + gq)

" Colorscheme.
" Will not exits on 1st call to PluginInstall -> need a catch
try
    colorscheme dracula
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme darkblue
endtry

" Define indentation default
filetype plugin indent on
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set shiftwidth=2    " number of spaces to use for autoindent
set expandtab       " tabs are space
set autoindent
set copyindent      " copy indent from the previous line
" Make needs hard tabs
autocmd BufRead,BufNewFile make noexpandtab

" Make tabs and trailing spaces visible
set list
set listchars=tab:>-,trail:-

" Sensible find
set path+=**
set wildmenu

" Remove those pesky temp files
set nobackup
set noswapfile

" Sane encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set bomb


