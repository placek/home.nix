{ config
, pkgs
, ...
}:
let
  vim-xit = pkgs.vimUtils.buildVimPlugin {
    pname = "xit-vim";
    version = "v0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "sadotsoy";
      repo = "vim-xit";
      rev = "9b2c60b5da69670e1b8066c3e96bedbe6067699b";
      sha256 = "sha256-edAFJMxIpvkWqRoYB17E7jERyN40heFCBjpeliazRYg=";
    };
  };
in
{
  config.programs.vim.plugins = [
    vim-xit
    pkgs.vimPlugins.vim-polyglot
  ];
}
