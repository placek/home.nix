{ pkgs, glpkgs, settings, ... }:
let
  git-ctags = import ./git-ctags.nix { inherit pkgs; };
  qutebrowser-gl = import ./qutebrowser-gl.nix { inherit pkgs glpkgs; };
  kitty-gl = import ./kitty-gl.nix { inherit pkgs glpkgs; };
  custom-nerdfonts = import ./custom-nerdfonts.nix { inherit pkgs settings; };
in
with pkgs; [
  glpkgs.nixGLIntel

  custom-nerdfonts
  git-ctags
  kitty-gl
  qutebrowser-gl

  curl
  fd
  file
  git-crypt
  imagemagick
  killall
  mdcat
  openssl
  openvpn
  qtpass
  ripgrep
  rlwrap
  rnix-lsp
  universal-ctags
  unrar
  unzip
  wget
  yq
  wl-clipboard
]
