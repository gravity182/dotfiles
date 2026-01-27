"        _
" __   _(_)_ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|
"
" Additions to this awesome config - https://github.com/amix/vimrc
"
" if something ain't working try running with a clean configuration: vim --clean
"


" ====================
" Options
" ====================

" make Vim more useful
set nocompatible

" this block is required when running inside tmux and for some themes
" see this issue https://github.com/vim/vim/issues/993#issuecomment-241255881
" also read :h xterm-true-color
if exists('+termguicolors')
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" colorscheme
" colorscheme catppuccin_mocha
colorscheme onedark
set background=dark

" yank, delete, and put commands will use the system clipboard
" prefer the "+ register on X11 (clipboard selection)
" WSL is supported too - just install vim-gtk with clipboard support
if has('unnamedplus')
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

set encoding=UTF-8

" backups, swapfiles, and persistent undo history
set writebackup
set backupdir=~/.vim/tmp/backups
set backupskip=/tmp/*
set directory=~/.vim/tmp/swaps
set undofile
set undodir=~/.vim/tmp/undo

" Copy indent from current line when starting a new line
set autoindent

" Respect modeline in files
set modeline
set modelines=4

" show line numbers
set number

" tabs and spaces
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
" Use spaces instead of tabs when inserting
set expandtab
set smarttab

" display tabs explicitly
" this is useful cause I don't wanna have tabs in my files at all
" spaces are always better
set list
set listchars=tab:>-

" do not enable binary mode by default
set nobinary

" add empty newlines at the end of files
set eol
set fixeol

" Highlight current line
set cursorline
set cursorlineopt=number,line

" Always show status line
set laststatus=2

" Don’t reset cursor to start of line when moving around.
set nostartofline

" Show the cursor position
set ruler

" Allow backspace in insert mode
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1

" Resize panes when window/terminal gets resize
autocmd VimResized * :wincmd =

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

set nocompatible

" automatically set CWD to the current buffer's path
" :lcd means that CWD will be window-local (compared to :cd)
" it's a safer alternative to 'autochdir'
autocmd BufEnter * silent! lcd %:p:h

" set default timeout values explicitly
" timeoutlen is a mapping delay and ttimeoutlen is a key code delay
" these values should make vim more responsive
set timeout ttimeout timeoutlen=1000 ttimeoutlen=100

" Disable linebreak
set nolinebreak
set tw=0

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Allow cursor keys in insert mode
set esckeys

" Optimize for fast terminal connections
set ttyfast

" Do not add the g flag to search/replace by default
set nogdefault

" enhance command-line completions
"
" While the completion is active, navigate with the following keys:
" CTRL-P    - go to the previous entry
" CTRL-N    - go to the next entry
" <CR>      - in menu completion, when the cursor is just after a dot: move into a submenu
" CTRL-E    - end completion, go back to what was there before selecting a match
" CTRL-Y    - accept the currently selected match and stop completion
set wildmenu

set cmdheight=1

set scrolloff=7
set sidescroll=1
set sidescrolloff=2
set display+=truncate

set autoread

" Delete comment character when joining commented lines
set formatoptions+=j

" Disable a legacy behavior that can break plugin maps
if has('langmap') && exists('+langremap') && &langremap
    set nolangremap
endif


" ====================
" GUI
" ====================

" configure cursor shape
if &term =~? 'rxvt' || &term =~? 'xterm' || &term =~? 'st-' || &term =~? 'tmux-' || &term =~? 'screen-'
    " www.reddit.com/r/vim/comments/uvizcu/comment/i9majz5

    " 1 or 0 -> blinking block
    " 2 -> solid block
    " 3 -> blinking underscore
    " 4 -> solid underscore
    " 5 -> blinking vertical bar
    " 6 -> solid vertical bar

    " Normal Mode
    let &t_EI .= "\<Esc>[2 q"
    " Insert Mode
    let &t_SI .= "\<Esc>[6 q"
    " Replace Mode
    let &t_SR .= "\<Esc>[4 q"
elseif $TERM_PROGRAM =~? "iterm"
    " see https://iterm2.com/documentation/2.1/documentation-escape-codes.html
    let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=2\x7" " Underscore in replace mode
endif

if has("gui_running")
    " Set extra options when running in GUI mode
    set guioptions-=T
    set guioptions-=e
    set guitablabel=%M\ %t

    if has("gui_macvim")
        " set nerd font (required for vim-devicons)
        " for terminal vim set it in the terminal's settings itself
        set guifont=SauceCodeProNF:h15
        " configure window size
        set lines=28
        set columns=110

        " Properly disable sound on errors on MacVim
        autocmd GUIEnter * set vb t_vb=
    endif
endif


" ====================
" Key maps
" ====================

" With a map leader it's possible to do extra key combinations
" " like <leader>w saves the current file
let mapleader = ","

" remove <space> mappings
nnoremap <SPACE> <Nop>
nnoremap <C-SPACE> <Nop>

" map leader to Space button
map <Space> <Leader>

" disable mouse support - use keyboard only
set mouse=

" Disable highlight when <leader><cr> is pressed
nmap <silent> <leader><cr> :noh<cr>

" navigate through quickfix errors in the buffer
map <C-j> :cn<CR>
map <C-k> :cp<CR>

" map redo to 'r'
nnoremap <C-r> <Nop>
nnoremap r <C-r>
" same undo/redo behaviour as in IDEA
nmap <D-z> r
nmap <D-S-z> u

" find
" search in the current buffer with ctrl-f (forward)
nnoremap <C-f> /
" search for the current selection
xnoremap <silent> <C-f> :<C-u>call VisualSelection('', '', 0)<CR>/<C-R>=@/<CR><CR>
xnoremap <silent> / :<C-u>call VisualSelection('', '', 0)<CR>/<C-R>=@/<CR><CR>
xnoremap <silent> * :<C-u>call VisualSelection('', '', 0)<CR>/<C-R>=@/<CR><CR>
xnoremap <silent> # :<C-u>call VisualSelection('', '', 0)<CR>?<C-R>=@/<CR><CR>

" substitute
" type replacement after another slash
" i.e. :s/replace_this/with_this
nnoremap <C-r> :s/
" substitute with the selected text as a search pattern
xnoremap <silent> <C-r> :call VisualSelection('replace', '', 0)<CR>

" Toggle paste mode on and off
" also sets the expandtab option so that tabs in the pasted content is replaced with spaces
nmap <silent> <leader>pp :setlocal paste!<cr>:setlocal expandtab<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Useful mappings for managing buffers
" Close the current buffer
nmap <leader>bd :Bclose<cr>:tabclose<cr>gT
nmap <leader>bc <leader>bd
" Close all buffers
nmap <leader>ba :bufdo bd<cr>

" Useful mappings for managing tabs
nmap <leader>tn :tabnew<cr>
nmap <leader>to :tabonly<cr>
nmap <leader>tc :tabclose<cr>
nmap <leader>tm :tabmove<space>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <silent> <leader>tl :exe "tabn ".g:lasttab<CR>
autocmd TabLeave * let g:lasttab = tabpagenr()

" allows switching tabs via <Alt> + <Arrow>
nmap <Esc>[1;3D gT
nmap <Esc>[1;3C gt

" Super useful when editing files in the same directory
" Open a file with the current buffer's path prefilled
nmap <leader>e :edit <C-r>=escape(expand("%:p:h"), " ")<cr>/
" Open a file in a new tab with the current buffer's path prefilled
nmap <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Go to tab by number
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<cr>

" Scroll tabs
nnoremap <D-S-Left>  :tabprevious<CR>
nnoremap <D-S-Right> :tabnext<CR>
nmap <SwipeLeft> gT
nmap <SwipeRight> gt

" visual select a word under the cursor
nnoremap gw viw

" Remap 0 to first non-blank character
nmap 0 ^

" make Y yank to the end of line, which is more logical
nmap Y y$

" Move a line of text using Alt+[jk] or Command+[jk]
nmap <silent> <M-j> mz:m+<cr>`z
nmap <silent> <M-k> mz:m-2<cr>`z
xmap <silent> <M-j> :m'>+<cr>`<my`>mzgv`yo`z
xmap <silent> <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
    nmap <D-j> <M-j>
    nmap <D-k> <M-k>
    xmap <D-j> <M-j>
    xmap <D-k> <M-k>
endif

" Switch CWD with the directory of the open buffer preselected
nmap <leader>cd :cd <C-r>=escape(expand("%:p:h"), " ")<cr>/

" save/exit mappings

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" save the current buffer
nmap <leader>w  :w<cr>
nmap <leader>q  :q<cr>

" unmap Ex mode
nnoremap Q <nop>


" ====================
" Filetypes
" ====================

" Markdown
" --------

autocmd BufRead,BufFilePre,BufNewFile *.MD,*.md set filetype=markdown

" Shell script
" ------------

" Correctly highlight $() and other modern affordances in filetype=sh.
if !exists('g:is_posix') && !exists('g:is_bash') && !exists('g:is_kornshell') && !exists('g:is_dash')
    let g:is_posix = 1
endif

" Man
" ---

" Enable the :Man command shipped inside Vim's man filetype plugin.
if exists(':Man') != 2 && !exists('g:loaded_man') && &filetype !=? 'man' && !has('nvim')
    runtime ftplugin/man.vim
endif


" ====================
" Plugins
" ====================

" --------------------
" https://github.com/easymotion/vim-easymotion
" :help easymotion
" --------------------

" map <leader><leader> <Plug>(easymotion-prefix)

" " Enable/Disable default mappings
" let g:EasyMotion_do_mapping = 1

" " Jump to anywhere you want with minimal keystrokes, with just one key binding.
" " `s{char}{label}`
" " nmap s <Plug>(easymotion-overwin-f)
" " or
" " `s{char}{char}{label}`
" " Need one more keystroke, but on average, it may be more comfortable.
" " nmap f <Plug>(easymotion-overwin-f2)

" " Turn on case-insensitive feature
" let g:EasyMotion_smartcase = 1

" " JK motions: Line motions
" map <leader>j <Plug>(easymotion-j)
" map <leader>k <Plug>(easymotion-k)


" --------------------
" https://github.com/preservim/nerdtree
" :help NERDTree
" --------------------

let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize=35
let g:NERDTreeShowHidden=0
let g:NERDTreeQuitOnOpen=3
let g:NERDTreeBookmarksSort=0
let g:NERDTreeIgnore = ['\.git', '\.pyc$', '__pycache__', '\.cache$', '\.android$', '\.ansible$', '\.gnupg', '\.iterm2$', '\.hawtjni$', '\.subversion$', '\.terraform.d$', '\.threaddeath$', '\.Trash$', '\.vscode$', '\.yarn$', '\.zsh_sessions$', '\.sdkman$', '\.DS_Store']
" start NERDTree when Vim is started without file arguments.
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

nnoremap <silent> <expr> <leader>n g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"


" --------------------
" https://github.com/simnalamburt/vim-mundo
" :help mundo
" --------------------

nnoremap <silent> <leader>u :MundoToggle<CR>
let g:mundo_preview_bottom = 1


" --------------------
" https://github.com/preservim/vim-indent-guides
" :help indent_guides
" --------------------

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=gray     ctermbg=gray
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=darkgrey ctermbg=darkgrey


" --------------------
" https://github.com/tpope/vim-commentary
" :help commentary
" --------------------

nmap <leader>cc gcc
nmap <leader>cp gcap
xmap <leader>c gc


" --------------------
" https://github.com/junegunn/vim-easy-align
" :help vim-easy-align
" --------------------

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" custom delimiters
" see defaults - https://github.com/junegunn/vim-easy-align/blob/2.9.6/autoload/easy_align.vim#L32-L46
if !exists('g:easy_align_delimiters')
    let g:easy_align_delimiters = {}
endif
let g:easy_align_delimiters['#'] = { 'pattern': '#', 'ignore_groups': ['String'] }

" If a delimiter is in a highlight group whose name matches any of the followings, it will be ignored
" e.g. mapping keysheet section at the top of this config won't be aligned by default
let g:easy_align_ignore_groups = ['Comment']


" --------------------
" https://github.com/itchyny/lightline.vim
" :help lightline
" --------------------

let g:lightline = {
    \ 'colorscheme': 'catppuccin_mocha',
    \ 'active': {
    \   'left':  [
    \              [ 'mode', 'paste' ],
    \              [ 'readonly', 'filename', 'modified' ],
    \            ],
    \   'right': [
    \              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
    \              [ 'lineinfo' ],
    \              [ 'percent' ],
    \              [ 'fileformat', 'fileencoding', 'filetype' ],
    \              [ 'fugitive' ],
    \            ],
    \ },
    \ 'component_expand': {
    \   'linter_checking': 'lightline#ale#checking',
    \   'linter_infos': 'lightline#ale#infos',
    \   'linter_warnings': 'lightline#ale#warnings',
    \   'linter_errors': 'lightline#ale#errors',
    \   'linter_ok': 'lightline#ale#ok',
    \ },
    \ 'component_type': {
    \   'linter_checking': 'right',
    \   'linter_infos': 'right',
    \   'linter_warnings': 'warning',
    \   'linter_errors': 'error',
    \   'linter_ok': 'right',
    \ },
    \ 'component_function': {
    \   'filetype': 'AleFiletype',
    \ },
    \ 'component': {
    \   'readonly': '%{&filetype=="help"?"":&readonly?"\ue672":""}',
    \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
    \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())'
    \ },
    \ 'separator': { 'left': ' ', 'right': ' ' },
    \ 'subseparator': { 'left': ' ', 'right': '|' }
\ }

function! AleFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : '?') : ''
endfunction

" let g:lightline#ale#indicator_checking = "\uf110"
" let g:lightline#ale#indicator_infos = "\uf129"
" let g:lightline#ale#indicator_warnings = "\uf071"
" let g:lightline#ale#indicator_errors = "\uf05e"
" let g:lightline#ale#indicator_ok = "\uf00c"

" mode is already displayed by lightline
set noshowmode


" --------------------
" https://github.com/junegunn/fzf.vim
" :help fzf-vim
" --------------------

nnoremap <leader>ff  :Files<CR>

nnoremap <leader>;   :History<CR>

nnoremap <leader>fc  :Commands<CR>

nnoremap <leader>fch :History:<CR>

nnoremap ;           :Buffers<CR>
nnoremap <leader>fb  :Buffers<CR>

nnoremap <leader>fm  :Maps<CR>

nnoremap <leader>fs  :Snippets<CR>

nnoremap <leader>fg  :Commits<CR>

nnoremap <leader>g   :Rg<Space>
nnoremap <C-g>       :Rg<Space>

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Hide statusline when a fzf window opens
" https://github.com/junegunn/fzf/blob/master/README-VIM.md#hide-statusline
autocmd! FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

if !exists("g:fzf_opts_initiated")
    let $FZF_DEFAULT_OPTS .= "--border rounded
      \ --layout default
      \ --info 'inline-right'
      \ --separator '─'
      \ --prompt '∷ '
      \ --pointer '>'
      \ --marker '>'
      \ "
    let g:fzf_opts_initiated = 1
endif

" popup window (center of the screen))
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

command! -bar -bang Maps call fzf#vim#maps("n", <bang>0)
command! -bar -bang MapsN call fzf#vim#maps("n", <bang>0)
command! -bar -bang MapsV call fzf#vim#maps("v", <bang>0)
command! -bar -bang MapsX call fzf#vim#maps("x", <bang>0)
command! -bar -bang MapsI call fzf#vim#maps("i", <bang>0)


" --------------------
" ripgrep
" --------------------

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case
    " see https://www.reddit.com/r/vim/comments/gmbc03/comment/fr2qne5
    set grepformat^=%f:%l:%c:%m

    " customize $FZF_DEFAULT_COMMAND and :Rg if you want
    "let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
    command! -bang -nargs=* Rg call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)

    " Rg selection
    vnoremap <leader>g :call VisualSelection('rg', '', 0)<cr>
    vnoremap <C-g> :call VisualSelection('rg', '', 0)<cr>
endif


" --------------------
" https://github.com/junegunn/vim-journal
" :help journal
" --------------------

" you can also put the journal notes as .txt under notes/ directory
" then it will be recognized as journal filetype
" see https://github.com/junegunn/vim-journal/pull/8/files
autocmd BufRead,BufNewFile *.journal set filetype=journal


" --------------------
" https://github.com/tmsvg/pear-tree
" :help pear-tree
" --------------------

let g:pear_tree_repeatable_expand = 0

let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1

let g:pear_tree_pairs = {
    \ '(': {'closer': ')'},
    \ '[': {'closer': ']'},
    \ '{': {'closer': '}'},
    \ "'": {'closer': "'"},
    \ '"': {'closer': '"'},
    \ '`': {'closer': '`'}
\ }

augroup pear_tree_pairs_html
    autocmd!
    autocmd FileType html let b:pear_tree_pairs = {
            \ '<*>': {'closer': '</*>'}
            \ }
augroup END


" --------------------
" https://github.com/sirver/ultisnips
" :h UltiSnips
" --------------------

" from the docs:
" If you have g:UltiSnipsExpandTrigger and g:UltiSnipsJumpForwardTrigger set to the same value then the function you are actually going to use is UltiSnips#ExpandSnippetOrJump
" this behaviour works perfectly for me
let g:UltiSnipsExpandTrigger = "<c-j>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
let g:UltiSnipsListSnippets = "<c-tab>"


" --------------------
" https://github.com/machakann/vim-highlightedyank
" --------------------

let g:highlightedyank_highlight_in_visual = 0


" --------------------
" https://github.com/junegunn/limelight.vim
" --------------------

" " Color name (:help cterm-colors) or ANSI code
" let g:limelight_conceal_ctermfg = 240

" " Color name (:help gui-colors) or RGB color
" let g:limelight_conceal_guifg = '#777777'


" autocmd! User GoyoEnter Limelight
" autocmd! User GoyoLeave Limelight!


" --------------------
" https://github.com/christoomey/vim-tmux-navigator
" --------------------

" write the current buffer when navigating from Vim to tmux,
" but only if changed
let g:tmux_navigator_save_on_switch = 1

" this allows switching between tmux and vim panes when inside Nerdtree pane
" see https://github.com/christoomey/vim-tmux-navigator/issues/205
let g:NERDTreeMapJumpPrevSibling = ""
let g:NERDTreeMapJumpNextSibling = ""

" I had to comment this out because this simply doesn't work
" additional mappings in addition to the default ones (Ctrl + h/j/k/l)
" seemingly ctrl/alt + arrow keys work only in gui vim
" nmap <ESC>[1;5D] <C-Left>
" nmap <ESC>[1;5C] <C-Right>
" nmap <ESC>[5D <C-Left>
" nmap <ESC>[5C <C-Right>
" map! <ESC>[5D <C-Left>
" map! <ESC>[5C <C-Right>
" nnoremap <silent> <C-Left>       :<C-U>TmuxNavigateLeft<cr>
" nnoremap <silent> <C-Down>       :<C-U>TmuxNavigateDown<cr>
" nnoremap <silent> <C-Up>         :<C-U>TmuxNavigateUp<cr>
" nnoremap <silent> <C-Right>      :<C-U>TmuxNavigateRight<cr>

" --------------------
" https://github.com/terryma/vim-smooth-scroll
" --------------------

noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>


" ====================
" Miscellaneous
" ====================

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! CmdLineCR(str)
    call feedkeys(":" . a:str . "\<CR>")
endfunction

function! VisualSelection(direction, extra_filter, cr) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'rg'
        if (a:cr == 1)
            call CmdLineCR("Rg " . l:pattern)
        else
            call CmdLine("Rg " . l:pattern)
        endif
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
