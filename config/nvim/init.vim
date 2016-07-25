set nocompatible
let iCanHazNeoBundle=1
let neobundle_readme=expand($HOME.'/.config/nvim/bundle/neobundle.vim/README.md')
if !filereadable(neobundle_readme)
    echo "Installing NeoBundle.."
    echo ""
    silent !mkdir -p $HOME/.config/nvim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim $HOME/.config/nvim/bundle/neobundle.vim
    let iCanHazNeoBundle=0
endif
if has('vim_starting')
    set rtp+=$HOME/.config/nvim/bundle/neobundle.vim/
endif
call neobundle#begin(expand($HOME.'/.config/nvim/bundle/'))
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'NLKNguyen/papercolor-theme'
NeoBundle 'croaker/mustang-vim'
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'bkad/CamelCaseMotion'
NeoBundle 'Shougo/neocomplcache.vim'
NeoBundle 'groenewege/vim-less'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ervandew/supertab'
NeoBundle 'mustache/vim-mustache-handlebars'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'mhinz/vim-startify'
NeoBundle 'tpope/vim-surround'
NeoBundle 'bling/vim-airline'
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'osyo-manga/vim-over'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'wellle/targets.vim'
NeoBundle 'thinca/vim-qfreplace'
NeoBundle 'junegunn/vim-easy-align'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'junegunn/seoul256.vim'
call neobundle#end()

filetype plugin indent on
set tabstop=2
set shiftwidth=2
set expandtab

set tags=./.ctags,.ctags;

syntax enable
set t_Co=256

if exists('light')
  set background=light
  colo PaperColor
  let g:airline_theme='PaperColor'
else
  set background=dark
  colo mustang
  let g:airline_theme='understated'
endif

let mapleader=" "
nnoremap j gj
nnoremap k gk
nnoremap J 5j
nnoremap K 5k
nnoremap <Leader>ff :CtrlP<CR>
map <Leader>fs :CtrlPTag<CR>
map <Leader>fd :CtrlPCurFile<CR>
map <Leader>fb :CtrlPBuffer<CR>
nmap <Leader><Leader> <c-^>
inoremap jj <ESC>
inoremap jk <ESC>
imap <C-e> <C-o>$
imap <C-a> <C-o>0
imap <C-f> <C-o>l
imap <C-b> <C-o>h
tnoremap jj <C-\><C-n>
set clipboard=unnamed
nnoremap <Esc><Esc> :nohlsearch<CR>


" Scripts
"
function! RenewTagsFile()
    exe 'silent !rm -rf .ctags'
    exe 'silent !ctags -a -Rf .ctags --languages=javascript --exclude=.git --exclude="*.min.js" --exclude=node_modules --exclude=tmp 2>/dev/null'
    exe 'redraw!'
endfunction

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

function! VisualFindAndReplace()
    :OverCommandLine%s/
    :w
endfunction
nnoremap <Leader>fr :call VisualFindAndReplace()<CR>

function! VisualFindAndReplaceWithSelection() range
    :'<,'>OverCommandLine s/
    :w
endfunction
xnoremap <Leader>fr :call VisualFindAndReplaceWithSelection()<CR>

function! Incr()
    let a = line('.') - line("'<")
    let c = virtcol("'<")
    if a > 0
        execute 'normal! '.c.'|'.a."\<C-a>"
    endif
    normal `<
endfunction
vnoremap <C-a> :call Incr()<CR>

function! RenewTagsFile()
    exe 'silent !rm -rf .ctags'
    exe 'silent !ctags -a -Rf .ctags --languages=javascript --exclude=.git --exclude="*.min.js" --exclude=node_modules --exclude=tmp 2>/dev/null'
    exe 'redraw!'
endfunction
nnoremap <Leader>ri :call RenewTagsFile()<CR>


" Mustache
"
let g:mustache_abbreviations = 1

if has("autocmd")
  au BufNewFile,BufRead *.{mustache,handlebars,hbs}{,.erb} set filetype=html syntax=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim
endif

" Keybindings: Window resize
"
nnoremap <Left> :vertical resize +1<CR>
nnoremap <Right> :vertical resize -1<CR>
nnoremap <Up> :resize +1<CR>
nnoremap <Down> :resize -1<CR>

" Keybindings: Visual Find Replace
"
nnoremap <Leader>fr :call VisualFindAndReplace()<CR>
xnoremap <Leader>fr :call VisualFindAndReplaceWithSelection()<CR>

" Airline
"
set laststatus=2                                    " Make the second to last line of vim our status line
let g:airline_left_sep=''                           " No separator as they seem to look funky
let g:airline_right_sep=''                          " No separator as they seem to look funky
let g:airline#extensions#branch#enabled = 0         " Do not show the git branch in the status line
let g:airline#extensions#syntastic#enabled = 1      " Do show syntastic warnings in the status line
let g:airline#extensions#tabline#show_buffers = 0   " Do not list buffers in the status line
let g:airline_section_x = ''                        " Do not list the filetype or virtualenv in the status line
let g:airline_section_y = '[R%04l,C%04v] [LEN=%L]'  " Replace file encoding and file format info with file position
let g:airline_section_z = ''                        " Do not show the default file position info
let g:airline#extensions#virtualenv#enabled = 0

" Syntastic
"
let g:syntastic_check_on_open=1                   " check for errors when file is loaded
let g:syntastic_loc_list_height=5                 " the height of the error list defaults to 10

let g:syntastic_python_checkers = ['flake8']      " sets flake8 as the default for checking python files
let g:syntastic_python_flake8_post_args='--ignore=E111'

let g:syntastic_javascript_checkers = ['eslint']  " sets jshint as our javascript linter
" let g:syntastic_javascript_jshint_post_args='--esversion 6'
let g:syntastic_filetype_map = { 'handlebars.html': 'handlebars' }
let g:syntastic_mode_map={ 'mode': 'active',
                     \ 'active_filetypes': [],
                     \ 'passive_filetypes': ['html', 'handlebars'] }

" CTRLP
"
let g:ctrlp_use_caching=0
let g:ctrlp_custom_ignore = '\v[\/](transpiled)|dist|tmp|env|node_modules|(\.(swp|git|bak|pyc|DS_Store))$'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_max_files=0
let g:ctrlp_max_height = 18
let g:ctrlp_open_multiple_files = '1vjr'
let g:ctrlp_buffer_func = { 'enter': 'MyCtrlPMappings' }
let g:ctrlp_reuse_window = 'startify'
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden --ignore .git --ignore .DS_Store --ignore "**/*.pyc" -g ""'

" Startify
"
let g:startify_change_to_dir = 0
hi StartifyHeader ctermfg=124
let g:startify_show_files = 1
let g:startify_show_files_number = 10
let g:startify_bookmarks = [ '~/.vimrc' ]

" Emmet
"
let g:user_emmet_install_global = 0
autocmd FileType html,htmldjango,handlebars EmmetInstall
let g:user_emmet_leader_key=','

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

" Jedi (needs pip install jedi and pip3 install jedi)
" 
let g:jedi#auto_vim_configuration = 0
let g:jedi##use_tabs_not_buffers = 0     " Use buffers not tabs
let g:jedi#popup_on_dot = 0
let g:jedi#rename_command = "<leader>rn"
let g:jedi#goto_command = "<leader>f"
let g:jedi#show_call_signatures = "0"
let g:jedi#documentation_command = "<leader>m"

" Work scripts
"
if isdirectory("xcalibur")
  " Touch bootstrap.less if we find one in the xcalibur dir
  autocmd BufWritePost *.less :silent !touch `find xcalibur -name "bootstrap.less" | head -1`
  let g:syntastic_javascript_checkers = ['jshint']  " sets jshint as our javascript linter
  let g:syntastic_python_checkers = []      " sets flake8 as the default for checking python files
  let g:syntastic_python_flake8_post_args=''
endif
