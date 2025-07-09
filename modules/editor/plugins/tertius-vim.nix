{ config
, pkgs
, ...
}:
let
  tertius-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "tertius-vim";
    version = "1.0.0.1";
    src = ./tertius-vim;
  };
in
{
  config.programs.vim.plugins = [ tertius-vim ];
}
