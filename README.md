# vim-textobj-python

This is a Vim plugin to provide text objects for Python functions and classes.  It provides the following objects:

- `af`: a function
- `if`: inner function
- `ac`: a class
- `ic`: inner class

It also provides a few motions in normal and operator-pending mode:

- `[pf` / `]pf`: move to next/previous function
- `[pc` / `]pc`: move to next/previous class

## Installation

It requires kana's [vim-textobj-user](https://github.com/kana/vim-textobj-user), version 0.4.0 or better. I recommend installing both `vim-textobj-user` and `vim-textobj-python` with [pathogen](https://github.com/tpope/vim-pathogen).

## Configuration

If you'd like to change the default mappings (whether for personal prefence or avoiding conflict with e.g. [vim-textobj-function](https://github.com/kana/vim-textobj-function)), add the following to `~/.vim/after/ftplugin/python.vim`:

    xmap aF <Plug>(textobj-python-function-a)
    omap aF <Plug>(textobj-python-function-a)
    xmap iF <Plug>(textobj-python-function-i)
    omap iF <Plug>(textobj-python-function-i)

This will map `if` and `af` to `iF` and `aF`, respectively.

## TODO

- Skip improperly-indented comment lines
- Handle inner function on multiline def one-liner:

```python
def foo(bar,
        baz): pass
```
