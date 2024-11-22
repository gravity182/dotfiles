# Dotfiles

This is my dotfiles repo.
Look around, maybe you'll find something useful for yourself.

Basic overview of the essential utils I personally use daily:
- [zsh](https://www.zsh.org/)
- [vim](https://www.vim.org/)
- [tmux](https://github.com/tmux/tmux)
- [fzf](https://github.com/junegunn/fzf) - fuzzy finder
- [ripgrep](https://github.com/BurntSushi/ripgrep) - like `grep` but better
- [fd-find](https://github.com/sharkdp/fd) - like `find` but better
- [zoxide](https://github.com/ajeetdsouza/zoxide) - like `cd` but better
- [bat](https://github.com/sharkdp/bat) - like `cat` but better
- [ncdu](https://dev.yorhel.nl/ncdu) - file explorer
- [jq](https://github.com/jqlang/jq) - json manipulation
- [delta](https://github.com/dandavison/delta) - git diff pager

All of them are already preconfigured.

## Quick start

First, put the repository's content into your home directory. For example:
```shell
cd ~
git clone git@github.com:blinky-z/dotfiles.git dotfiles
mv dotfiles/* dotfiles/.* .
rm -rf dotfiles
```

Then run:
```shell
./.config/yadm/bootstrap
```

The bootstrap scripts, which you can find in [.config/yadm](../.config/yadm), will configure your shell and install all the required utils. I recommend you to look at the scripts yourself and adjust setup to your liking before running. High chances are you don't need everything I use.

