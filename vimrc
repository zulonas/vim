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
Plug 'ntpeters/vim-better-whitespace'
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

" Disable Ex mode
nnoremap Q <Nop>

" Remove trailing spaces with <F12>
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
else
	set clipboard=unnamed
endif


"" WSL clipboard support
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

function! ReplaceCurrentWord()
    let search_string = expand("<cword>")
    let replace_string = input('Replace: ', search_string)
    if replace_string == "" || replace_string == search_string
        return
    endif
    execute '%s/\<' . search_string . '\>/' . replace_string . '/gc'
endfunction
nnoremap <F2> :call ReplaceCurrentWord()<CR>

function! GenerateTagsAndCscope()
    silent !ctags -R
    silent !cscope -Rb
    redraw!
    echo "Generated"
endfunction
nnoremap <leader>t :call GenerateTagsAndCscope()<CR>

" Spell-check Markdown files and Git Commit Messages
autocmd FileType markdown setlocal spell
autocmd FileType gitcommit setlocal spell

" Alias
command! Wq wq
command! W w
command! Q q

" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set cscopeverbose


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif

" -------------------- PLUGINS ------------------------

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
nmap <leader>gb :Git blame<CR>
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
