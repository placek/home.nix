{ pkgs
, ...
}:
pkgs.vimUtils.buildVimPlugin {
  pname = "vim-dirvish-dovish";
  version = "04c77b6";
  src = pkgs.fetchFromGitHub {
    owner = "roginfarrer";
    repo = "vim-dirvish-dovish";
    rev = "04c77b6010f7e45e72b4d3c399c120d42f7c5d47";
    sha256 = "sha256-8uw1Ft48JVphhdhd9TBcB3b9NFBRkwdEQH2LZblE1dk=";
  };
}
