# Dotfiles

This is my dotfiles repo.
I spent a lot of time optimizing my setup and especially the zsh setup.
An ordinary zsh session starts in under ~110 ms.

What can be generated dynamically is generated dynamically during the bootstrap stage. This allows the repo to stay lightweight and guarantees you always get the up-to-date configuration. For instance, vim plugins and completion scripts are generated dynamically.

Basic overview of the essential utils I personally use daily:
- [zsh](https://www.zsh.org/) - shell. Configured to work in a vim mode
- [vim](https://www.vim.org/) - editor. Comes with a bunch of useful plugins (inspect them all - [.vim/plugins.vim](../.vim/plugins.vim))
- [tmux](https://github.com/tmux/tmux) - terminal multiplexer
- [fzf](https://github.com/junegunn/fzf) - fuzzy finder
- [ripgrep](https://github.com/BurntSushi/ripgrep) - like `grep` but better
- [fd-find](https://github.com/sharkdp/fd) - like `find` but better
- [zoxide](https://github.com/ajeetdsouza/zoxide) - like `cd` but better
- [bat](https://github.com/sharkdp/bat) - like `cat` but better
- [jq](https://github.com/jqlang/jq) - json manipulation
- [delta](https://github.com/dandavison/delta) - git diff pager
- [ncdu](https://dev.yorhel.nl/ncdu) - file explorer

All of them are already preconfigured.

## Quick start

First, put the repository's content into your home directory. For example:
```shell
cd ~
git clone https://github.com/blinky-z/dotfiles.git dotfiles
mv -n dotfiles/* dotfiles/.* . && rm -rf dotfiles
```

Then run:
```shell
./.config/yadm/bootstrap
```

The bootstrap scripts, which you can find in [.config/yadm](../.config/yadm), will configure your shell and install all the required utils. I recommend you to look at the scripts yourself and adjust the setup to your liking before running. High chances are you don't need everything I use.

