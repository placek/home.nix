{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-expand-region
    ];
  };
}
