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
          if !exists('b:lsp')
            return ""
          endif
          let l:counts = lsp#get_buffer_diagnostics_counts()
          let l:total = 0
          for value in values(l:counts)
            let l:total += value
          endfor
          return l:total == 0 ? "OK" : printf('%dE %dW %dH %dI', l:counts.error, l:counts.warning, l:counts.hint, l:counts.information)
        endfunction

        function! s:lspOnBufferEnabled() abort
          setlocal omnifunc=lsp#complete
          setlocal signcolumn=yes
          if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

          let g:lsp_format_sync_timeout = 1000
          let g:lsp_diagnostics_virtual_text_enabled = 1
          let b:lsp = 1
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
