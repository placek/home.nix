{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        " fetch an answer for the selected text
        function! s:askOyVeySelected()
          let l:text = <sid>selectedText()
          if empty(l:text)
            return
          endif
          let l:solution = system('tertius ask', l:text)
          let lines = split(l:solution, "\n")
          for i in range(len(lines))
            let lines[i] = printf(&commentstring, lines[i])
          endfor
          call append(line('.'), lines)
        endfunction

        vnoremap <leader>y :call <sid>askOyVeySelected()<cr>

        " generate a pull request description
        function! s:oyVeyPullRequestDescription()
          call <sid>openIntermediateBuffer()
          file /tmp/pull-request-description
          let l:summary = substitute(system("tertius pull-request write"), '\r', "", 'g')
          execute "0put =l:summary"
          redraw!
          autocmd! BufWinLeave <buffer> call s:updatePullRequestDescription()
        endfunction

        " update the pull request description
        function! s:updatePullRequestDescription()
          if !<sid>isBufferEmpty()
            execute ":%!tertius pull-request publish"
          endif
        endfunction

        " open a window for issue description
        function! s:prepareIssue()
          call <sid>openIntermediateBuffer()
          file /tmp/issue-description
          nnoremap <buffer> <cr> :<c-u>call <sid>oyVeyIssue()<cr>
          autocmd! BufWinLeave <buffer> call s:reportIssue()
        endfunction

        nnoremap <leader>N :call <sid>prepareIssue()<cr>

        " generate an issue description
        function! s:oyVeyIssue()
          execute ":%!tertius story write"
          redraw!
        endfunction

        " report an issue
        function! s:reportIssue()
          if !<sid>isBufferEmpty()
            let l:type = input("branch type /", "")
            execute ":%!tertius story publish " . l:type
          endif
        endfunction

        " generate a commit message
        function! s:oyVeyCommitMessage()
          execute ":%!tertius commit write-message"
          normal! ggVGgq
          redraw!
        endfunction

        autocmd! FileType gitcommit nnoremap <buffer> <cr> :<c-u>call <sid>oyVeyCommitMessage()<cr>

        " fetch an explanation and solution for the selected error
        function! s:oyVeyFixError()
          let l:loclist = ale#engine#GetLoclist(bufnr('%'))
          if empty(l:loclist)
            return
          endif
          let [l:lnum, l:col] = getpos('.')[1:2]
          let l:item_under_cursor = filter(l:loclist, {_, v -> v.lnum == l:lnum && v.col <= l:col && (has_key(v, 'end_col') ? v.end_col : v.col) >= l:col})
          if empty(l:item_under_cursor)
            return
          endif
          let l:item = l:item_under_cursor[0]
          let messages = {
          \ 'E': 'an error',
          \ 'W': 'a warning',
          \ 'WS': 'a style warning',
          \ 'ES': 'a style error',
          \ 'I': 'some LSP info',
          \ }
          let l:detail = printf("The `%s` linter reported %s in file %s at line %d and column %s:\n%s", l:item.linter_name, l:messages[l:item.type], l:item.lnum, expand('%:.'), l:item.col, l:item.text)
          let l:solution = system('tertius code fix ' . expand('%:p'), l:detail)
          let lines = split(l:solution, "\n")
          for i in range(len(lines))
            let lines[i] = printf(&commentstring, lines[i])
          endfor
          call append(line('.'), lines)
        endfunction

        nnoremap <localleader>Y :call <sid>oyVeyFixError()<cr>

        " fetch an explanation for the selected code
        function! s:oyVeyExplain()
          let l:text = <sid>selectedText()
          if empty(l:text)
            return
          endif
          let l:solution = system('tertius code explain', l:text)
          let lines = split(l:solution, "\n")
          for i in range(len(lines))
            let lines[i] = printf(&commentstring, lines[i])
          endfor
          call append(line('.'), lines)
        endfunction

        vnoremap <localleader>y :call <sid>oyVeyExplain()<cr>
      ''
    ];
  };
}
