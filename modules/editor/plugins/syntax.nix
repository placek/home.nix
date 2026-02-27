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
  vim-cypher = pkgs.vimUtils.buildVimPlugin {
    pname = "cypher-vim";
    version = "v0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "neo4j-contrib";
      repo = "cypher-vim-syntax";
      rev = "386abb72a5113dfd3aa88ab59bb1e99d3ff33c8e";
      sha256 = "sha256-iJLl5BPM5KV+WcnmYV0HSfYyBePXkPYy2nWeqy2VU+o=";
    };
  };
in
{
  config.programs.vim.plugins = [
    vim-xit
    vim-cypher
    pkgs.vimPlugins.vim-polyglot
  ];
}
