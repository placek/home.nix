{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-lsp
    ];

    editor.RCs = [
      ''
        function! LinterStatus() abort
          let l:counts = lsp#get_buffer_diagnostics_counts()
          let l:total = 0
          for value in values(l:counts)
            let l:total += value
          endfor
          return l:total == 0 ? 'OK' : printf('%dE %dW %dH %dI', l:counts.error, l:counts.warning, l:counts.hint, l:counts.information)
        endfunction

        function! s:lspOnBufferEnabled() abort
          setlocal omnifunc=lsp#complete
          setlocal signcolumn=yes
          if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
          nmap <buffer> <localleader>a <plug>(lsp-code-action-float)
          nmap <buffer> <localleader>A <plug>(lsp-document-format)
          vmap <buffer> <localleader>A <plug>(lsp-document-range-format)
          nmap <buffer> <localleader>d <plug>(lsp-definition)
          nmap <buffer> <localleader>D <plug>(lsp-type-definition)
          nmap <buffer> <localleader>f <plug>(lsp-references)
          nmap <buffer> <localleader>s <plug>(lsp-status)
          nmap <buffer> <localleader>g <plug>(lsp-implementation)
          nmap <buffer> <localleader>G <plug>(lsp-workspace-symbol-search)
          nmap <buffer> <leader>rn <plug>(lsp-rename)
          nmap <buffer> [e <plug>(lsp-previous-diagnostic)
          nmap <buffer> ]e <plug>(lsp-next-diagnostic)
          nmap <buffer> K <plug>(lsp-hover-float)

          let g:lsp_format_sync_timeout = 1000
          let g:lsp_diagnostics_echo_cursor = 1
        endfunction

        hi lspReference cterm=underline
        hi LspErrorText ctermbg=0 ctermfg=1
        hi LspErrorHighlight ctermbg=0 ctermfg=1 cterm=underline
        hi LspHintText ctermbg=0 ctermfg=4
        hi LspHintHighlight ctermbg=0 ctermfg=4 cterm=underline
        hi LspWarningText ctermbg=0 ctermfg=3
        hi LspWarningHighlight ctermbg=0 ctermfg=3 cterm=underline
        hi LspInformationText ctermbg=0 ctermfg=8
        hi LspInformationHighlight ctermbg=0 ctermfg=8 cterm=underline
      ''
    ];
  };
}
