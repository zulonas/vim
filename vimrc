" Don't try to be vi compatible
set nocompatible

" Check vim-plug (plugin manager)
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
filetype off
call plug#begin('~/.vim/plugs')
Plug 'preservim/nerdtree'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'editorconfig/editorconfig-vim'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-unimpaired'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
filetype plugin indent on

" Security
set modelines=0

" Line numbers
set number

" Encoding
set encoding=utf-8

" Scroll behavior
set scrolloff=15

" Better rendering
set ttyfast

" Disable status line
set laststatus=0

" Colors
syntax enable
set t_Co=256
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1

" Search matching
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Enable hidden buffers
set hidden

" Maintain visual mode after shifting > and <
vmap < <gv
vmap > >gv

" Enable paste mode
set paste

" Set ruller
set ruler

" Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

" Disable Ex mode mapping
nnoremap Q <Nop>

" Remove trailing spaces
function ShowSpaces(...)
	let @/='\v(\s+$)|( +\ze\t)'
	let oldhlsearch=&hlsearch
	if !a:0
		let &hlsearch=!&hlsearch
	else
		let &hlsearch=a:1
	end
	return oldhlsearch
endfunction
function TrimSpaces() range
	let oldhlsearch=ShowSpaces(1)
	execute a:firstline.",".a:lastline."substitute ///gec"
	let &hlsearch=oldhlsearch
endfunction
command -bar -nargs=? ShowSpaces call ShowSpaces(<args>)
command -bar -nargs=0 -range=% TrimSpaces <line1>,<line2>call TrimSpaces()
nnoremap <F12> :ShowSpaces 1<CR>
nnoremap <F12> m`:TrimSpaces<CR>``

" Highlight all occurrences of the current word
nnoremap <F8> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

" Format json (requires jq)
function FormatJson()
	silent set syntax=json
	silent %! jq .
endfunction
command Json call FormatJson()

" Clipboard support
if has('unnamedplus')
	set clipboard=unnamed,unnamedplus
endif


"" WSL clipboard support(auto detect)
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip)
	augroup WSLYank
		autocmd!
		autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
	augroup END
endif


" Highlight line number
set cursorline
set cursorlineopt=number
autocmd ColorScheme * highlight CursorLineNr ctermbg=NONE

" Disable fast jumping(when using shift) in normal/visual mode
nnoremap <silent> <S-Up> :-5<CR>
nnoremap <silent> <S-Down> :+5<CR>
vnoremap <silent> <S-Up> -5
vnoremap <silent> <S-Down> +5

" -------------------- PLUGINS ------------------------

" #### Fakeclip ####
" let g:fakeclip_terminal_multiplexer_type = 'tmux'

" #### Gruvbox #####
autocmd vimenter * ++nested colorscheme gruvbox

" #### NerdTree ####
" Toggle
function! ToggleNERDTreeFind()
    if g:NERDTree.IsOpen()
	execute ':NERDTreeClose'
    else
	execute ':NERDTreeFind'
    endif
endfunction
nnoremap <C-n> :call ToggleNERDTreeFind()<CR>

" Update
nmap <Leader>r :NERDTreeFocus<CR>R<C-W><C-P>

" Disable status line
let g:NERDTreeStatusline = ""

" Close normaly when nerdclose is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Nerdtree ignore
let NERDTreeIgnore=['\.o$', '\~$', '\.swp$', ]


" #### Airline #####
" show only tabbar
let g:airline#extensions#tabline#enabled = 1
let b:airline_disable_statusline = 1


" #### Fugitive ####
nmap <leader>gb :Gblame<CR>
nmap <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>dp V:diffput<CR>
nnoremap <silent> <leader>dg V:diffget<CR>


" #### FZF ####
" Prevent FZF commands from opening in none modifiable buffers
function! FZFOpen(cmd)
    " If more than 1 window, and buffer is not modifiable or file type is
    " NERD tree or Quickfix type
    if winnr('$') > 1 && (!&modifiable || &ft == 'nerdtree' || &ft == 'qf')
	" Move one window to the right, then up
	wincmd l
	wincmd k
    endif
    exe a:cmd
endfunction

" fzf mapings
nnoremap <silent> <C-p> :call FZFOpen(":Files")<CR>
nnoremap <silent> <leader>F :Ag <C-R><C-W><CR>
nnoremap <silent> <leader>f :Ag <CR>


" #### Git-gutter ####
nmap <F10> :GitGutterLineHighlightsToggle<CR>


" #### vim-buffkill ####
nmap <leader>q :BD<cr>
