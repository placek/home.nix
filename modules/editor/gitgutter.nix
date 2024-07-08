{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-gitgutter
    ];

    editor.RCs = [
      ''
        " gitgutter
        nnoremap ]h :GitGutterNextHunk<cr>
        nnoremap [h :GitGutterPrevHunk<cr>
      ''
    ];
  };
}
