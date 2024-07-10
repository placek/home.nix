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
        let g:copilot_no_tab_map = v:true
      ''
    ];
  };
}
