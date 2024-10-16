{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        " fetch an answer for the selected text
        function! s:tertiusAsk() abort
          let l:text = <sid>selectedText()
          if empty(l:text)
            return
          endif
          let l:solution = system('${config.tertiusExec} ask', l:text)
          call <sid>appendComment(l:solution)
        endfunction

        vnoremap <silent> <Plug>(TertiusAsk) :<c-u>call <sid>tertiusAsk()<cr>

        " generate a pull request description
        function! s:tertiusPullRequestWindow() abort
          call <sid>openIntermediateBuffer()
          file /tmp/pull-request-description
          let l:summary = substitute(system("${config.tertiusExec} pull-request write"), '\r', "", 'g')
          execute "0put =l:summary"
          redraw!
          autocmd! BufWinLeave <buffer> call <sid>tertiusUpdatePullRequest()
        endfunction

        nnoremap <silent> <Plug>(TertiusPullRequestWindow) :<c-u>call <sid>tertiusPullRequestWindow()<cr>

        " update the pull request description
        function! s:tertiusUpdatePullRequest() abort
          if !<sid>isBufferEmpty()
            execute ":%!${config.tertiusExec} pull-request publish"
          endif
        endfunction

        nnoremap <silent> <Plug>(TertiusUpdatePullRequest) :<c-u>call <sid>tertiusUpdatePullRequest()<cr>

        " open a window for issue description
        function! s:tertiusIssueWindow() abort
          call <sid>openIntermediateBuffer()
          file /tmp/issue-description
          nnoremap <buffer> <cr> <Plug>(TertiusIssue)<cr>
          autocmd! BufWinLeave <buffer> call <sid>tertiusReportIssue()
        endfunction

        nnoremap <silent> <Plug>(TertiusIssueWindow) :<c-u>call <sid>tertiusIssueWindow()<cr>

        " report an issue
        function! s:tertiusReportIssue() abort
          if !<sid>isBufferEmpty()
            let l:type = input("branch type /", "")
            execute ":%!${config.tertiusExec} story publish " . l:type
          endif
        endfunction

        nnoremap <silent> <Plug>(TertiusReportIssue) :<c-u>call <sid>tertiusReportIssue()<cr>

        " generate an issue description
        function! s:tertiusIssue() abort
          execute ":%!${config.tertiusExec} story write"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusIssue) :<c-u>call <sid>tertiusIssue()<cr>

        function! s:tertiusGetStoryID() abort
          return trim(system("${config.tertiusExec} story id"))
        endfunction

        " generate a commit message
        function! s:tertiusCommitMessage() abort
          execute ":%!${config.tertiusExec} commit write-message"
          normal! ggVGgq
          let l:story_id = <sid>tertiusGetStoryID()
          if !empty(l:story_id)
            execute "0put ='['.l:story_id.']'"
            normal! ggJ
          endif
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusCommitMessage) :<c-u>call <sid>tertiusCommitMessage()<cr>

        " fetch an explanation and solution for the selected error
        function! s:tertiusFixCode() abort
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
          let l:solution = system('${config.tertiusExec} code fix ' . expand('%:p'), l:detail)
          call <sid>appendComment(l:solution)
        endfunction

        nnoremap <silent> <Plug>(TertiusFixCode) :<c-u>call <sid>tertiusFixCode()<cr>

        " fetch an explanation for the selected code
        function! s:tertiusExplain() abort
          let l:text = <sid>selectedText()
          if empty(l:text)
            return
          endif
          let l:solution = system('${config.tertiusExec} code explain', l:text)
          call <sid>appendComment(l:solution)
        endfunction

        vnoremap <silent> <Plug>(TertiusExplain) :<c-u>call <sid>tertiusExplain()<cr>
      ''
    ];
  };
}
