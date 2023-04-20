{ pkgs, glpkgs, ... }:
let
  git-ctags = import ./git-ctags.nix { inherit pkgs; };
  qutebrowser-gl = import ./qutebrowser-gl.nix { inherit pkgs glpkgs; };
  kitty-gl = import ./kitty-gl.nix { inherit pkgs glpkgs; };
  xpass = import ./xpass.nix { inherit pkgs; };
  custom-nerdfonts = import ./custom-nerdfonts.nix { inherit pkgs; };
in
with pkgs; [
  glpkgs.nixGLIntel

  custom-nerdfonts
  git-ctags
  kitty-gl
  qutebrowser-gl
  xpass

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
  ydotool
  yq
  wl-clipboard
]
