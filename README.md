# vim-hare

I forked an [old version](https://github.com/glittershark/vim-hare) of this
plugin since it hadn't been updated in two years. This version is documented and
it works, but it doesn't have all of HaRe's features.

## Installation

First, install HaRe with [stack](https://haskellstack.org). Then you can install
the plugin. To do so using [vim-plug](https://github.com/junegunn/vim-plug), add
the following to your `.vimrc`:

```vim
Plug 'vmchale/vim-hare
```

## Configuration

vim-hare provides keybindings, but you have to activate them yourself. This is
what I have in my `.vimrc`:

```vim
au BufNewFile,BufRead *.hs nnoremap lu <Plug>LiftHare
```
