function! s:altFile()
  if exists("b:altfile")
    if bufwinid(b:altfile) > -1
      call win_gotoid(bufwinid(b:altfile))
    else
      silent execute ":vs" b:altfile
    endif
  endif
endfunction

function! s:commentToggle()
  let line = getline('.')
  if l:line =~ '^\s*' . substitute(&commentstring, '%s', '.*', '')
    call setline('.', substitute(l:line, '^\s*\zs' . substitute(&commentstring, '%s', '', ''), '', ''))
  else
    call setline('.', printf(&commentstring, l:line))
  endif
endfunction

function! s:openQuickfix(new_split_cmd)
  let l:qf_idx = line('.')
  wincmd p
  execute a:new_split_cmd
  execute l:qf_idx . 'cc'
endfunction

" toggle loclist list
function! s:toggleLocList()
  if empty(filter(getwininfo(), 'v:val.loclist'))
    lopen
  else
    lclose
  endif
endfunction

" toggle quickfix list
function! s:toggleQuickFix()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
  else
    cclose
  endif
endfunction

" open a new buffer for intermediate operations
function! s:openIntermediateBuffer()
  wincmd n
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal syntax=markdown
endfunction

" checks if a buffer is empty
function! s:isBufferEmpty()
  if line('$') == 1 && getline(1) == ''
    return 1
  else
    return 0
  endif
endfunction

" checks if a buffer is empty, but contains comments
function! s:isBufferEmptyButComments()
  for i in range(1, line('$'))
    let line = substitute(getline(i), '^\s*', '', '')
    if line != '' && line[0] != '#'
      return 0
    endif
  endfor
  return 1
endfunction

" returns a text under visual selection
function! s:selectedText()
  silent normal gv"vy
  let l:selection = getreg('v')
  let l:escaped   = escape(l:selection, '\/')
  let l:regexp    = substitute(l:escaped, "\n", "\\\\n", "g")
  normal \<Esc>
  return l:regexp
endfunction

" triggers a buffer search using a given query
function! s:findTextInBuffer(register, query)
  call setreg(a:register, "\\V" . a:query)
  normal n
endfunction

" append the text to the current buffer as a comment
function! s:appendComment(text) abort
  let lines = split(a:text, "\n")
  for i in range(len(lines))
    let lines[i] = printf(&commentstring, lines[i])
  endfor
  call append(line('.'), lines)
endfunction

" make folds and return to manual foldmethod
function! s:makeFolds()
  setlocal foldmethod=indent
  norm zR
  setlocal foldmethod=manual
endfunction
