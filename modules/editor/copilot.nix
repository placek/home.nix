{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.copilot-vim
    ];

    editor.RCs = [
      ''
        inoremap <silent><script><expr> <f11> copilot#Accept("\<cr>")
        imap <F10> <Plug>(copilot-previous)
        imap <F12> <Plug>(copilot-next)
        imap <F9> <Plug>(copilot-suggest)
        let g:copilot_no_tab_map = v:true
      ''
    ];
  };
}
