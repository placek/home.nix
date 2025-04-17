{ config
, pkgs
, ...
}:
{
  config = {
    programs.vim.plugins = [
      pkgs.vimPlugins.vim-surround
      pkgs.vimPlugins.vim-repeat
    ];
  };
}
