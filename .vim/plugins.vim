call plug#begin('~/.vim/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'

Plug 'christoomey/vim-tmux-navigator'

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

if isdirectory(expand('~/.fzf'))
  Plug '~/.fzf'
elseif isdirectory('/opt/homebrew/opt/fzf')
  Plug '/opt/homebrew/opt/fzf'
elseif isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf'
endif
Plug 'junegunn/fzf.vim'

Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'junegunn/vim-journal'
Plug 'machakann/vim-highlightedyank'

Plug 'lifepillar/vim-gruvbox8'

call plug#end()
