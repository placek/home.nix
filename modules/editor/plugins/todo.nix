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
      ''
    ];
  };
}
