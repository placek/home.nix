{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        " compose a commit message from the output of `tertius commit` from the current buffer
        function! s:gitComposeCommitMessage(buffer_content) abort
          let l:result = split(trim(system("${config.tertiusExec} commit", a:buffer_content)), '\n')
          let l:user_story_id = <sid>gitUserStoryId(<sid>gitLastEmptyCommit())
          if !empty(l:user_story_id)
            let l:result[0] = "[" . l:user_story_id . "] " . l:result[0]
          endif
          normal! ggVGd
          call append(0, l:result)
          normal! GVggjgq
        endfunction

        " get the buffer content after the first commented line (including the commented line)
        function! s:gitCommitMessageTail(buffer_content) abort
          let l:index = 0
          for l:line in a:buffer_content
            if l:line !~ '^#'
              let l:index += 1
            else
              break
            endif
          endfor
          call append(line('$'), a:buffer_content[l:index:])
        endfunction

        " generate a commit message
        function! s:tertiusCommitMessage() abort
          let l:buffer_content = getline(1, '$')
          call <sid>gitComposeCommitMessage(l:buffer_content)
          call <sid>gitCommitMessageTail(l:buffer_content)
          execute '1'
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusCommitMessage) :<c-u>call <sid>tertiusCommitMessage()<cr>

        " generate a pull request description
        function! s:tertiusMergeRequestWindow() abort
          call <sid>openIntermediateBuffer('tertius_merge_request')
          let l:summary = substitute(system("${config.tertiusExec} pull-request"), '\r', "", 'g')
          execute "0put =l:summary"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusMergeRequestWindow) :<c-u>call <sid>tertiusMergeRequestWindow()<cr>

        " open a window for issue description
        function! s:tertiusUserStoryWindow() abort
          call <sid>openIntermediateBuffer('tertius_user_story')
          if <sid>isBufferEmpty()
            let l:commit_message = <sid>gitUserStoryFromCommit(<sid>gitLastEmptyCommit())
            call setline(1, l:commit_message)
          endif
        endfunction

        nnoremap <silent> <Plug>(TertiusUserStoryWindow) :<c-u>call <sid>tertiusUserStoryWindow()<cr>

        " generate an issue description
        function! s:tertiusUserStory() abort
          execute ":%!${config.tertiusExec} story"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusUserStory) :<c-u>call <sid>tertiusUserStory()<cr>

        function! s:tertiusTodo() abort
          execute ":%!${config.tertiusExec} todo"
          redraw!
        endfunction

        nnoremap <silent> <Plug>(TertiusTodo) :<c-u>call <sid>tertiusTodo()<cr>
      ''
    ];
  };
}
