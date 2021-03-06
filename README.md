# vim-hare

I forked an [old version](https://github.com/glittershark/vim-hare) of this
plugin since it hadn't been updated in two years. This version is documented and
it works, but it doesn't have all of HaRe's features.

## Installation

First, install HaRe with [cabal](https://www.haskell.org/cabal/), viz.

```bash
 $ cabal new-install HaRe -w ghc-8.0.2
```

Once that's done, you can install the plugin.
To do so using [vim-plug](https://github.com/junegunn/vim-plug), add
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

## Use

  * `:Hreplace newName` - Rename the identifier under the cursor to `newName`
  * `:Hlift` - Lift a function to top-level
  * `:Happlicative` - Generalize a monadic function to an applicative one
