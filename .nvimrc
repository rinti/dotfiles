if &compatible
  set nocompatible
endif

call plug#begin('~/.vim/plugged')
  Plug 'michaeljsmith/vim-indent-object'
  Plug 'trevordmiller/nova-vim'
  Plug 'bkad/CamelCaseMotion'
  Plug 'hail2u/vim-css3-syntax'
  Plug 'tpope/vim-fugitive'
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx'
  Plug 'scrooloose/syntastic'
  Plug 'tpope/vim-commentary'
  Plug 'mhinz/vim-startify'
  Plug 'airblade/vim-gitgutter'
  Plug 'kien/rainbow_parentheses.vim'
  Plug 'wellle/targets.vim'
  Plug 'junegunn/vim-easy-align'
  Plug 'mileszs/ack.vim'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'tpope/vim-vinegar'
  Plug 'w0ng/vim-hybrid'
  Plug 'RRethy/vim-hexokinase', {'do': 'make hexokinase'}
  Plug 'elixir-editors/vim-elixir'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

" Required:
filetype plugin indent on
syntax enable

" set background=dark
colo dracula
set termguicolors

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set inccommand=nosplit

set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

set colorcolumn=100
hi ColorColumn guibg=#334149
set signcolumn=yes
hi SignColumn guibg=clear

augroup VimCSS3Syntax
  autocmd!

  autocmd FileType css setlocal iskeyword+=-
augroup END

let mapleader=" "
nnoremap j gj
nnoremap k gk
nnoremap J 5j
nnoremap K 5k
nnoremap <Leader>ff :Files<CR>
nmap <Leader><Leader> <c-^>
imap <C-e> <C-o>$
imap <C-a> <C-o>0
imap <C-f> <C-o>l
imap <C-b> <C-o>h
set clipboard=unnamed
tnoremap jj <C-\><C-n>


" Exit insert mode with jj or jk
inoremap jj <ESC>
inoremap jk <ESC>

" Esc-Esc = Remove highlight
nnoremap <Esc><Esc> :nohlsearch<CR>

" Bind Alt-j and Alt-k to insert blank lines
function! AddEmptyLineBelow()
  call append(line("."), "")
endfunction

function! AddEmptyLineAbove()
  let l:scrolloffsave = &scrolloff
  " Avoid jerky scrolling with ^E at top of window
  set scrolloff=0
  call append(line(".") - 1, "")
  if winline() != winheight(0)
    silent normal! <C-e>
  end
  let &scrolloff = l:scrolloffsave
endfunction
noremap <silent> <C-j> :call AddEmptyLineBelow()<CR>
noremap <silent> <C-k> :call AddEmptyLineAbove()<CR>


" Scripts
"
function! CopyFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        redraw!
    endif
endfunction
map <Leader>cf :call CopyFile()<CR>

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <Leader>rf :call RenameFile()<CR>

function! Incr()
    let a = line('.') - line("'<")
    let c = virtcol("'<")
    if a > 0
        execute 'normal! '.c.'|'.a."\<C-a>"
    endif
    normal `<
endfunction
vnoremap <C-a> :call Incr()<CR>

set tags=./.ctags,.ctags;
function! RenewTagsFile()
    exe 'silent !rm -rf .ctags'
    exe 'silent !ctags -a -Rf .ctags --languages=javascript,python --exclude=.git --exclude="*.min.js" --exclude=node_modules --exclude=tmp 2>/dev/null'
    exe 'redraw!'
endfunction
nnoremap <Leader>ri :call RenewTagsFile()<CR>

" Hexokinase
let g:Hexokinase_optInPatterns = 'full_hex,triple_hex,rgb,rgba,hsl,hsla,colour_names'
let g:Hexokinase_ftEnabled = ['css', 'scss']

" Deoplete
"
" let g:deoplete#enable_at_startup = 1

" Mustache
"
let g:mustache_abbreviations = 1

if has("autocmd")
  au BufNewFile,BufRead *.{mustache,handlebars,hbs}{,.erb} set filetype=html syntax=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim
endif

if has("autocmd")
  au BufNewFile,BufRead *.{svelte} set filetype=html
endif

" Keybindings: Window switch
"
nnoremap <Left> :wincmd h<CR>
nnoremap <Right> :wincmd l<CR>
nnoremap <Up> :wincmd k<CR>
nnoremap <Down> :wincmd j<CR>

" Keybindings: Window resize
"
nnoremap <S-Left> :vertical resize +1<CR>
nnoremap <S-Right> :vertical resize -1<CR>
nnoremap <S-Up> :resize +1<CR>
nnoremap <S-Down> :resize -1<CR>

" Ack
"
" let g:ackprg = 'ag --vimgrep'
let g:ackprg = 'rg --vimgrep -g "!*migration*"'
map <Leader>a :Ack!<space>

set statusline^=%{coc#status()}

" Syntastic
"
let g:syntastic_check_on_open=1                   " check for errors when file is loaded
let g:syntastic_loc_list_height=1                 " the height of the error list defaults to 10
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=0

let g:syntastic_python_checkers = ['flake8']      " sets flake8 as the default for checking python files
let g:syntastic_python_flake8_post_args='--ignore=W503'

let g:syntastic_javascript_checkers = ['eslint']  " sets jshint as our javascript linter
" let g:syntastic_javascript_jshint_post_args='--esversion 6'
let g:syntastic_mode_map={ 'mode': 'active',
                     \ 'active_filetypes': [],
                     \ 'passive_filetypes': ['html'] }

" Startify
"
let g:startify_change_to_dir = 0
hi StartifyHeader ctermfg=124
let g:startify_show_files = 1
let g:startify_show_files_number = 10
let g:startify_bookmarks = [ '~/.vimrc' ]


" Rainbow parentheses
"
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['red',         'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ]
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0

" CamelCase Motion
"
map <silent> W <Plug>CamelCaseMotion_w
map <silent> E <Plug>CamelCaseMotion_e
map <silent> B <Plug>CamelCaseMotion_b
omap <silent> iW <Plug>CamelCaseMotion_iw
xmap <silent> iW <Plug>CamelCaseMotion_iw
omap <silent> iE <Plug>CamelCaseMotion_ie
xmap <silent> iE <Plug>CamelCaseMotion_ie
omap <silent> iB <Plug>CamelCaseMotion_ib
xmap <silent> iB <Plug>CamelCaseMotion_ib

let g:coc_global_extensions = [
    \ 'coc-css',
    \ 'coc-elixir',
    \ 'coc-emmet',
    \ 'coc-eslint',
    \ 'coc-html',
    \ 'coc-pairs',
    \ 'coc-phpls',
    \ 'coc-prettier',
    \ 'coc-python',
    \ 'coc-snippets',
    \ 'coc-stylelint',
    \ 'coc-svg',
    \ 'coc-tsserver',
    \ 'coc-yank',
\ ]
nmap <silent> ff <Plug>(coc-definition)
nmap <silent> fy <Plug>(coc-type-definition)
nmap <silent> fi <Plug>(coc-implementation)
nmap <silent> fr <Plug>(coc-references)
inoremap <silent><expr> <c-space> coc#refresh()
command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 Prettier :CocCommand prettier.formatFile
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
autocmd CursorHold * silent call CocActionAsync('highlight')
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Netrw
"
let g:netrw_liststyle = 4
let g:netrw_banner = 0
let g:netrw_list_hide='\.pyc$,^\.DS_Store$,^\.git/$'
set wildignore=*.pyc,__pycache__/ "stuff to ignore when tab completing
set wildignore+=*DS_Store*
set wildignore+=*/node_modules
set wildignore+=.git,.gitkeep

" jsx
"
let g:jsx_ext_required = 0

"
" Fzf
let g:fzf_nvim_statusline=0
let g:fzf_files_options='--preview "cat {}"'

" virtualenv for docker complete
if has('python')
py << EOF
import os.path
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF
endif

" Coc
"

nnoremap <silent> D :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
