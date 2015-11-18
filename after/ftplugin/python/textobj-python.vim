" Text objects for Python
" Version 0.4.1
" Copyright (C) 2013 Brian Smyth <http://bsmyth.net>
" License: So-called MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

" Integration with https://github.com/kana/vim-textobj-function.
if !exists('b:textobj_function_select')
  let b:textobj_function_select = function('textobj#python#function_select')

  if exists('b:undo_ftplugin')
    let b:undo_ftplugin .= '|'
  else
    let b:undo_ftplugin = ''
  endif
  let b:undo_ftplugin .= 'unlet b:textobj_function_select'
endif


if exists('g:loaded_textobj_python')
  finish
endif

call textobj#user#plugin('python', {
\   'class': {
\       'sfile': expand('<sfile>:p'),
\       'select-a': '<buffer>ac',
\       'select-i': '<buffer>ic',
\       'select-a-function': 'textobj#python#class_select_a',
\       'select-i-function': 'textobj#python#class_select_i',
\       'pattern': '^\s*\zsclass \(.\|\n\)\{-}:',
\       'move-p': '<buffer>[pc',
\       'move-n': '<buffer>]pc',
\   },
\   'function': {
\       'sfile': expand('<sfile>:p'),
\       'select-a': '<buffer>af',
\       'select-i': '<buffer>if',
\       'select-a-function': 'textobj#python#function_select_a',
\       'select-i-function': 'textobj#python#function_select_i',
\       'pattern': '^\s*\zsdef \(.\|\n\)\{-}:',
\       'move-p': '<buffer>[pf',
\       'move-n': '<buffer>]pf',
\   }
\})

