{ config
, pkgs
, ...
}:
{
  config = {
    editor.RCs = [
      ''
        function! s:codexPrompt() abort
          let l:prompt = input('codex prompt / ')
          if empty(l:prompt)
            return
          endif
          execute 'vertical terminal codex "' . shellescape(l:prompt) . '"'
        endfunction

        nmap <Plug>(CodexPrompt) :call <sid>codexPrompt()<cr>

        function! s:codexPromptFile() abort
          let l:prompt = input('codex file prompt / ')
          if empty(l:prompt)
            return
          endif
          execute 'vertical terminal codex "In context of the file ' . expand('%:.') . ': ' . shellescape(l:prompt) . '"'
        endfunction

        nmap <Plug>(CodexPromptFile) :call <sid>codexPromptFile()<cr>
      ''
    ];
  };
}

