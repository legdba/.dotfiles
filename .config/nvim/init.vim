set nocompatible " Forget about old, embrace new!


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NVIM Plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin(expand('~/.config/nvim/plugged'))
"Plug 'scrooloose/nerdtree'
"Plug 'xuyuanp/nerdtree-git-plugin'
"Plug 'tpope/vim-commentary'
"Plug 'dracula/vim'
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
"Plug 'vim-scripts/grep.vim'
"Plug 'vim-scripts/CSApprox'
"Plug 'bronson/vim-trailing-whitespace'
"Plug 'Raimondi/delimitMate'
Plug 'majutsushi/tagbar'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-easytags'
Plug 'scrooloose/syntastic'
"Plug 'Yggdroot/indentLine'
"Plug 'avelino/vim-bootstrap-updater'
Plug 'hashivim/vim-terraform'
Plug 'hashivim/vim-packer'
Plug 'christoomey/vim-tmux-navigator' " seamless vim/tmux navigation
call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Seamless vim/tmux navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>


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
"set cursorline               " highlight current line
set showmatch                " highlight matching brace
set laststatus=2             " window will always have a status line
syntax on                    " enable syntax coloring
set textwidth=80             " 80-chars line wrapping (activate with v ... + gq)
set colorcolumn=80           " visual marker

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
set expandtab       " tabs are spaces
set autoindent
set copyindent      " copy indent from the previous line

" Make needs hard tabs
autocmd BufRead,BufNewFile make noexpandtab

" Make tabs and trailing-spaces visible
set list
set listchars=tab:>-,trail:-

" Sensible find
set path+=**
set wildmenu

" Remove pesky swap files but make sure backups are made
set nobackup
set nowritebackup
set noswapfile

" Sane encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set nobomb " BOM causes ASCII files not to work with /bin/env and other CLI


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Training mode ;)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>

vnoremap <Up> <Nop>
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Make the statusline usefull
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/airblade/vim-gitgutter
set updatetime=100

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntactic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

