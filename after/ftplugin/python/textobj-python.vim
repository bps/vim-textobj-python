" Vim additional ftplugin: textobj-python
" Version 0.3.1
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

" TODO Implement the class objects
" TODO Define motions
" TODO Skip improperly-indented comment lines
" FIXME Handle inner function on multiline def one-liner:
" def foo(bar,
"         baz): pass

if exists('g:loaded_textobj_python')
  finish
endif

call textobj#user#plugin('python', {
\   'class': {
\       '*sfile*': expand('<sfile>:p'),
\       'select-a': 'ac',
\       'select-i': 'ic',
\       '*select-a-function*': 's:class_select_a',
\       '*select-i-function*': 's:class_select_i'
\   },
\   'function': {
\       '*sfile*': expand('<sfile>:p'),
\       'select-a': 'af',
\       'select-i': 'if',
\       '*select-a-function*': 's:function_select_a',
\       '*select-i-function*': 's:function_select_i'
\   }
\})

function! s:class_select_a()
    return 0
endfunction

function! s:class_select_i()
    return 0
endfunction

function! s:function_select_a()
    let l:cur_pos = getpos('.')
    let l:cur_line = getline('.')
    " Start at a nonblank line
    if l:cur_line =~# '^\s*$'
        call cursor(prevnonblank(l:cur_pos[1]), 0)
        let l:cur_line = getline('.')
        let l:cur_pos = getpos('.')
    endif
    " Find the def line
    if l:cur_line =~# '^\s*def '
        let l:def_pos = l:cur_pos
    else
        while 1
            if search('^\s*def ', 'bW')
                let l:def_pos = getpos('.')
                if indent(l:def_pos[1]) >= indent(l:cur_pos[1])
                    " This is a def at the same level or deeper, keep searching
                    continue
                else
                    " Found the def
                    break
                endif
            else
                " We didn't find a suitable def
                return 0
            endif
        endwhile
    endif
    let l:def_indent_level = indent('.')

    " Find the last line of the method
    call cursor(l:cur_pos[1], l:cur_pos[2])
    let l:end_pos = getpos('.')
    while 1
        " Is this a one-liner?
        if getline('.') =~# '^\s*def\[^:\]\+:\s*\[^#\]'
            return ['V', l:def_pos, l:def_pos]
        endif
        " This isn't a one-liner, so skip the def line
        if line('.') == l:def_pos[1]
            normal! j
            continue
        endif
        if getline('.') !~# '^\s*$'
            if indent('.') > l:def_indent_level
                let l:end_pos = getpos('.')
            else
                break
            endif
        endif
        if line('.') == line('$')
            break
        else
            normal! j
        endif
    endwhile

    return ['V', l:def_pos, l:end_pos]
endfunction

function! s:function_select_i()
    let l:a_pos = s:function_select_a()
    if type(l:a_pos) != type([])
        return 0
    else
        if l:a_pos[1][1] == l:a_pos[2][1]
            " This is a one-liner, treat it like af
            " TODO Maybe change this to a 'v'-mode selection and only get the
            " statement from the one-liner?
            return l:a_pos
        endif
        " Put the cursor on the def line
        call cursor(l:a_pos[1][1], l:a_pos[1][2])
        " Get to the closing paren, then go down a line
        normal! f(%j0
        let l:start_pos = getpos('.')
        return ['V', l:start_pos, l:a_pos[2]]
    endif
endfunction

let g:loaded_textobj_python = 1
