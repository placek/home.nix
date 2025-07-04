{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        function! s:todoToggleWindow()
          silent call system('${config.vcsExec} notes --ref=todo copy HEAD~ HEAD')
          if buflisted(bufname('.git/NOTES_EDITMSG'))
            if !win_gotoid(bufwinid('.git/NOTES_EDITMSG'))
              execute ":split .git/NOTES_EDITMSG"
            endif
          else
            execute ":G notes --ref=todo edit"
          endif
          execute ":set syntax=xit filetype=xit"
          syntax match Comment /^#.*/ containedin=ALL
        endfunction

        nnoremap <silent> <Plug>(TodoToggle) :<c-u>call <sid>todoToggleWindow()<cr>

        function! s:todoGetNote()
          let l:note = system('${config.vcsExec} notes --ref=todo show HEAD 2>/dev/null')
          return substitute(l:note, '\n\+$', ''', ''')
        endfunction

        function! s:todoPutNote()
          let l:note = <SID>todoGetNote()
          " check if note is empty or contains only whitespace
          if empty(trim(l:note))
            return
          endif

          let l:lines = split(l:note, "\n")
          " prefix every line with #
          let l:commented_lines = map(l:lines, {_, val -> '# ' . val})
          let l:commented_note = join(l:commented_lines, "\n")

          execute "put ='# Actual TODOs:'"
          execute "put =l:commented_note"
          execute "put ='# ------------------------ 8< ------------------------'"
        endfunction

        nnoremap <silent> <Plug>(TodoPutNote) :<c-u>call <sid>todoPutNote()<cr>

        function! s:todoToggleItem()
          let l:line = getline('.')
          if l:line =~ '^\[[^x]\] '
            call setline('.', substitute(l:line, '^\[ \] ', '[x] ', ""))
          elseif l:line =~ '^\[x\] '
            call setline('.', substitute(l:line, '^\[x\] ', '[ ] ', ""))
          else
            call setline('.', substitute(l:line, '^\W*', '[ ] ', ""))
          endif
        endfunction

        nnoremap <silent> <Plug>(TodoToggleItem) :<c-u>call <sid>todoToggleItem()<cr>
      ''
    ];
  };
}
