{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        function! s:putCurrentGitHubIssue()
          let l:issue = substitute(system("${config.tertiusExec} story get"), '\r', "", 'g')
          execute "0put =l:issue"
          execute ":2,$s/^/    /"
        endfunction

        function! s:toggleTodoNote()
          silent call system('${config.vcsExec} notes --ref=todo copy HEAD~ HEAD')
          if buflisted(bufname('.git/NOTES_EDITMSG'))
            if !win_gotoid(bufwinid('.git/NOTES_EDITMSG'))
              execute ":split .git/NOTES_EDITMSG"
            endif
          else
            execute ":G notes --ref=todo edit"
          endif
          execute ":set syntax=xit"
          if <sid>isBufferEmptyButComments()
            execute "normal! ggVGd"
            call <sid>putCurrentGitHubIssue()
          endif
          syntax match Comment /^#.*/ containedin=ALL
        endfunction

        nnoremap <silent> <Plug>(TodoNote) :<c-u>call <sid>toggleTodoNote()<cr>

        function! s:getTodoNote()
          let l:note = system('${config.vcsExec} notes --ref=todo show HEAD')
          return l:note
        endfunction

        function! s:putTodoNote()
          let l:note = <sid>getTodoNote()
          let lines = split(l:note, "\n")
          let commented_lines = []
          for line in lines
            call add(commented_lines, '# ' . line)
          endfor
          let l:commented_note = join(commented_lines, "\n")
          execute "put ='# Actual TODOs:'"
          execute "put =l:commented_note"
          execute "put ='# ------------------------ 8< ------------------------'"
        endfunction

        nnoremap <silent> <Plug>(PutTodoNote) :<c-u>call <sid>putTodoNote()<cr>
      ''
    ];
  };
}
