{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        " generate a commit message
        function! s:tertiusCommitMessage() abort
          execute ":%!${config.tertiusExec} commit write-message"
          normal! ggVGgq
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusCommitMessage) :<c-u>call <sid>tertiusCommitMessage()<cr>

        " generate a pull request description
        function! s:tertiusPullRequestWindow() abort
          call <sid>openIntermediateBuffer()
          file /tmp/pull-request-description
          let l:summary = substitute(system("${config.tertiusExec} pull-request"), '\r', "", 'g')
          execute "0put =l:summary"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusPullRequestWindow) :<c-u>call <sid>tertiusPullRequestWindow()<cr>

        " open a window for issue description
        function! s:tertiusUserStoryWindow() abort
          call <sid>openIntermediateBuffer()
          file /tmp/issue-description
          nnoremap <buffer> <cr> <Plug>(TertiusUserStory)<cr>
        endfunction

        nnoremap <silent> <Plug>(TertiusUserStoryWindow) :<c-u>call <sid>tertiusUserStoryWindow()<cr>

        " generate an issue description
        function! s:tertiusUserStory() abort
          execute ":%!${config.tertiusExec} story"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusUserStory) :<c-u>call <sid>tertiusUserStory()<cr>
      ''
    ];
  };
}
