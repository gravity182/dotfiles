call plug#begin('~/.vim/plugged')
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'preservim/vim-indent-guides'
Plug 'sheerun/vim-polyglot'
Plug 'christoomey/vim-tmux-navigator'
Plug 'terryma/vim-smooth-scroll'

" Motions and text objects
" -------------------------
Plug 'michaeljsmith/vim-indent-object'
Plug 'dbakker/vim-paragraph-motion'

Plug 'tommcdo/vim-exchange'

Plug 'farmergreg/vim-lastplace'
Plug 'tpope/vim-repeat'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

Plug 'maxbrunsfeld/vim-yankstack'

Plug 'junegunn/goyo.vim'
" Plug 'junegunn/limelight.vim'
Plug 'amix/vim-zenroom2'

Plug 'junegunn/vim-easy-align'

Plug '~/.fzf'
Plug 'junegunn/fzf.vim'

Plug 'ryanoasis/vim-devicons'

Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'simnalamburt/vim-mundo'

Plug 'junegunn/vim-journal'

Plug 'tmsvg/pear-tree'

Plug 'machakann/vim-highlightedyank'

Plug 'junegunn/vim-peekaboo'


" Git
" -------------------------
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/vim-gist'


" Auto-completion & Snippets
" -------------------------
Plug 'sirver/ultisnips'
Plug 'honza/vim-snippets'


" Themes
" -------------------------
Plug 'joshdick/onedark.vim'
Plug 'liuchengxu/space-vim-theme'
Plug 'pineapplegiant/spaceduck'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

call plug#end()

