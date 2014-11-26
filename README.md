# vim-textobj-python

This is a Vim plugin to provide text objects for Python functions and classes.
It provides the following objects:

- `af`: a function
- `if`: inner function
- `ac`: a class
- `ic`: inner class

It also provides a few motions in normal and operator-pending mode:

- `[pf` / `]pf`: move to next/previous function
- `[pc` / `]pc`: move to next/previous class

## Installation

It requires kana's [vim-textobj-user](https://github.com/kana/vim-textobj-user),
version 0.4.0 or later. I recommend installing both `vim-textobj-user` and
`vim-textobj-python` with [pathogen](https://github.com/tpope/vim-pathogen).

## Configuration

If you'd like to change the default mappings (whether for personal preference
or to avoid conflicts with other plugins, define a global variable
`g:textobj_python_no_default_key_mappings` before this plugin is loaded
(typically in your vimrc):

    let g:textobj_python_no_default_key_mappings = 1

Then define the mappings with the helper function:

    call textobj#user#map('python', {
          \   'class': {
          \     'select-a': 'ac',
          \     'select-i': 'ic',
          \     'move-n': ']pc',
          \     'move-p': '[pc',
          \   },
          \   'function': {
          \     'select-a': 'af',
          \     'select-i': 'if',
          \     'move-n': ']pf',
          \     'move-p': '[pf',
          \   }
          \ })

You can also use `:TextobjPythonDefaultKeyMappings` to redefine the default
key mappings. This command doesn't override existing mappings, unless `[!]` is
given.

You can also manually define the mappings as follows:

    xmap aF <Plug>(textobj-python-function-a)
    omap aF <Plug>(textobj-python-function-a)
    xmap iF <Plug>(textobj-python-function-i)
    omap iF <Plug>(textobj-python-function-i)


## Unit tests

There are a few unit tests available in `test/`. They're written using
[Vader](https://github.com/junegunn/vader.vim).

[![Build Status](https://travis-ci.org/bps/vim-textobj-python.svg?branch=vader-tests)](https://travis-ci.org/bps/vim-textobj-python)

## TODO

- Skip improperly-indented comment lines
- Handle inner function on multiline def one-liner:

```python
def foo(bar,
        baz): pass
```
