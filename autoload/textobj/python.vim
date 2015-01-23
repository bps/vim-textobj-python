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

function! textobj#python#move_cursor_to_starting_line()
    " Start at a nonblank line
    let l:cur_pos = getpos('.')
    let l:cur_line = getline('.')
    if l:cur_line =~# '^\s*$'
        call cursor(prevnonblank(l:cur_pos[1]), 0)
    endif
endfunction

function! textobj#python#find_defn_line(kwd)
    " Find the defn line
    let l:cur_pos = getpos('.')
    let l:cur_line = getline('.')
    if l:cur_line =~# '^\s*'.a:kwd.' '
        let l:defn_pos = l:cur_pos
    else
        let l:cur_indent = indent(l:cur_pos[1])
        while 1
            if search('^\s*'.a:kwd.' ', 'bW')
                let l:defn_pos = getpos('.')
                let l:defn_indent = indent(l:defn_pos[1])
                if l:defn_indent >= l:cur_indent
                    " This is a defn at the same level or deeper, keep searching
                    continue
                else
                    " Found a defn, make sure there aren't any statements at a
                    " shallower indent level in between
                    for l:l in range(l:defn_pos[1] + 1, l:cur_pos[1])
                        if getline(l:l) !~# '^\s*$' && indent(l:l) <= l:defn_indent
                            throw "defn-not-found"
                        endif
                    endfor
                    break
                endif
            else
                " We didn't find a suitable defn
                throw "defn-not-found"
            endif
        endwhile
    endif
    call cursor(defn_pos)
    return l:defn_pos
endfunction

function! textobj#python#find_prev_decorators(l)
    " Find the line with the first (valid) decorator above `line`, return the
    " current line, if there is none.
    let linenr = a:l
    while 1
        let prev = prevnonblank(linenr-1)
        if prev == 0 || prev != linenr-1
            " Line is not above current one.
            break
        endif
        let prev_indent = indent(prev)
        if prev_indent != indent(linenr)
            " Line is not indented the same.
            break
        endif
        if getline(prev)[prev_indent] != "@"
            break
        endif
        let linenr = prev
    endwhile
    return linenr
endfunction

function! textobj#python#find_last_line(kwd, defn_pos, indent_level)
    " Find the last line of the block at given indent level
    let l:cur_pos = getpos('.')
    let l:end_pos = l:cur_pos
    while 1
        " Is this a one-liner?
        if getline('.') =~# '^\s*'.a:kwd.'\[^:\]\+:\s*\[^#\]'
            return a:defn_pos
        endif
        " This isn't a one-liner, so skip the def line
        if line('.') == a:defn_pos[1]
            normal! j
            continue
        endif
        if getline('.') !~# '^\s*$'
            if indent('.') > a:indent_level
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
    call cursor(l:cur_pos[1], l:cur_pos[2])
    return l:end_pos
endfunction

function! textobj#python#select_a(kwd)
    call textobj#python#move_cursor_to_starting_line()

    try
        let l:defn_pos = textobj#python#find_defn_line(a:kwd)
    catch /defn-not-found/
        return 0
    endtry
    let l:defn_indent_level = indent(l:defn_pos[1])

    let l:end_pos = textobj#python#find_last_line(a:kwd, l:defn_pos, l:defn_indent_level)

    let l:defn_pos[1] = textobj#python#find_prev_decorators(l:defn_pos[1])

    return ['V', l:defn_pos, l:end_pos]
endfunction

function! textobj#python#select_i(kwd)
    let l:a_pos = textobj#python#select_a(a:kwd)
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
        " Get to the closing parenthesis if it exists
        normal! ^f(%
        " Start from the beginning of the next line
        normal! j0
        let l:start_pos = getpos('.')
        return ['V', l:start_pos, l:a_pos[2]]
    endif
endfunction

function! textobj#python#class_select_a()
    return textobj#python#select_a('class')
endfunction

function! textobj#python#class_select_i()
    return textobj#python#select_i('class')
endfunction

function! textobj#python#function_select_a()
    return textobj#python#select_a('def')
endfunction

function! textobj#python#function_select_i()
    return textobj#python#select_i('def')
endfunction

function! textobj#python#function_select(object_type)
  return textobj#python#function_select_{a:object_type}()
endfunction
