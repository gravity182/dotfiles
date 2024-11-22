# Dotfiles

This is my dotfiles repo.
Look around, maybe you'll find something useful for yourself.

Basic overview of the essential utils I personally use daily:
- zsh
- vim
- fzf
- ripgrep
- fd-find
- zoxide for fast directory cd
- bat
- ncdu
- jq
- delta as a git diff pager

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

The bootstrap script, which you can find in [.config/yadm/bootstrap](../.config/yadm/bootstrap), will configure your shell and install all the required utils. I recommend you to look at the script yourself and adjust it for your needs before running. High chances are you don't need everything I use.

