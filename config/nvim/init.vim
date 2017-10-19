if &compatible
  set nocompatible
endif

set runtimepath+=/Users/andreas/.vim/bundles/repos/github.com/Shougo/dein.vim

if dein#load_state('/Users/andreas/.vim/bundles')
  call dein#begin('/Users/andreas/.vim/bundles')

  " Let dein manage dein
  " Required:
  call dein#add('Shougo/dein.vim')
  call dein#add('michaeljsmith/vim-indent-object')
  call dein#add('trevordmiller/nova-vim')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('bkad/CamelCaseMotion')
  call dein#add('hail2u/vim-css3-syntax')
  call dein#add('tpope/vim-fugitive')
  call dein#add('ervandew/supertab')
  call dein#add('pangloss/vim-javascript')
  call dein#add('mxw/vim-jsx')
  call dein#add('scrooloose/syntastic')
  call dein#add('kien/ctrlp.vim')
  call dein#add('tpope/vim-commentary')
  call dein#add('mhinz/vim-startify')
  call dein#add('tpope/vim-surround')
  call dein#add('bling/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  " call dein#add('airblade/vim-gitgutter')
  call dein#add('mattn/emmet-vim')
  call dein#add('kien/rainbow_parentheses.vim')
  call dein#add('wellle/targets.vim')
  call dein#add('junegunn/vim-easy-align')
  call dein#add('davidhalter/jedi-vim')
  call dein#add('mileszs/ack.vim')
  call dein#add('editorconfig/editorconfig-vim')
  call dein#add('tpope/vim-vinegar')
  call dein#add('w0ng/vim-hybrid')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set inccommand=nosplit

set colorcolumn=80

syntax enable
" set t_Co=256

set background=dark
set termguicolors
colo nova
" let g:airline_theme='understated'

augroup VimCSS3Syntax
  autocmd!

  autocmd FileType css setlocal iskeyword+=-
augroup END

let mapleader=" "
nnoremap j gj
nnoremap k gk
nnoremap J 5j
nnoremap K 5k
nnoremap <Leader>ff :CtrlP<CR>
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


" Deoplete
"
let g:deoplete#enable_at_startup = 1

" Mustache
"
let g:mustache_abbreviations = 1

if has("autocmd")
  au BufNewFile,BufRead *.{mustache,handlebars,hbs}{,.erb} set filetype=html syntax=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim
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
let g:ackprg = 'rg --vimgrep'
map <Leader>a :Ack!<space>

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
let g:syntastic_loc_list_height=1                 " the height of the error list defaults to 10
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

let g:syntastic_python_checkers = ['flake8']      " sets flake8 as the default for checking python files
let g:syntastic_python_flake8_post_args='--ignore=E111'

let g:syntastic_javascript_checkers = ['eslint']  " sets jshint as our javascript linter
" let g:syntastic_javascript_jshint_post_args='--esversion 6'
let g:syntastic_filetype_map = { 'handlebars.html': 'handlebars' }
let g:syntastic_mode_map={ 'mode': 'active',
                     \ 'active_filetypes': [],
                     \ 'passive_filetypes': ['html', 'handlebars'] }

let g:elm_syntastic_show_warnings = 1

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
let g:ctrlp_user_command = 'rg --files --ignore-case --follow --glob "!.git/*" %s'

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
let g:jedi#use_tabs_not_buffers = 0     " Use buffers not tabs
let g:jedi#popup_on_dot = 0
let g:jedi#rename_command = "<leader>rn"
let g:jedi#goto_command = "<leader>f"
let g:jedi#show_call_signatures = "0"
let g:jedi#documentation_command = "<leader>m"

" Netrw
"
let g:netrw_banner = 0
let g:netrw_list_hide= '.*\.pyc$'

" jsx
"
let g:jsx_ext_required = 0

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

" Work scripts
"
