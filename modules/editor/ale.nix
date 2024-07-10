{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.ale
    ];

    editor.RCs = [
      ''
        function! LinterStatus() abort
          let l:counts = ale#statusline#Count(bufnr(""))
          let l:all_errors = l:counts.error + l:counts.style_error
          let l:all_non_errors = l:counts.total - l:all_errors
          return l:counts.total == 0 ? 'OK' : printf('%dW %dE', all_non_errors, all_errors)
        endfunction

        let g:ale_close_preview_on_insert = 1
        let g:ale_completion_enabled = 1
        let g:ale_floating_preview = 0
        let g:ale_set_loclist = 1
        let g:ale_loclist_msg_format = '%severity%: %s'

        let g:ale_echo_cursor = 0

        let g:ale_sign_column_always = 1
        let g:ale_sign_error = 'E'
        let g:ale_sign_info = 'I'
        let g:ale_sign_style_error = 'ES'
        let g:ale_sign_style_warning = 'WS'
        let g:ale_sign_warning = 'W'

        let g:ale_virtualtext_cursor = 'all'
        let g:ale_virtualtext_prefix = '%comment% '

        set omnifunc=ale#completion#OmniFunc

        hi ALEVirtualTextError              ctermfg=1
        hi ALEVirtualTextWarning            ctermfg=4
        hi ALEVirtualTextInfo               ctermfg=5
        hi ALEError              ctermbg=0  ctermfg=1  cterm=underline
        hi ALEErrorSign          ctermbg=0  ctermfg=1
        hi ALEWarning            ctermbg=0  ctermfg=4  cterm=underline
        hi ALEWarningSign        ctermbg=0  ctermfg=4
        hi ALEInfo               ctermbg=0  ctermfg=5  cterm=underline
        hi ALEInfoSign           ctermbg=0  ctermfg=5
      ''
    ];
  };
}
