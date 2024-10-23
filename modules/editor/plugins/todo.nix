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
          execute ":set syntax=xit"
          syntax match Comment /^#.*/ containedin=ALL
        endfunction

        nnoremap <silent> <Plug>(TodoToggle) :<c-u>call <sid>todoToggleWindow()<cr>

        function! s:todoGetNote()
          let l:note = system('${config.vcsExec} notes --ref=todo show HEAD')
          return l:note
        endfunction

        function! s:todoPutNote()
          let l:note = <sid>todoGetNote()
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

        nnoremap <silent> <Plug>(TodoPutNote) :<c-u>call <sid>todoPutNote()<cr>
      ''
    ];
  };
}
