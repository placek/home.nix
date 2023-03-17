{ pkgs, ... }:
let
  settings = import ../settings;
  nixglpkgs = (import (builtins.fetchTarball { url = "https://github.com/guibou/nixGL/archive/main.tar.gz"; }) { });
in
with pkgs; [
  nixglpkgs.nixGLIntel
  (pkgs.writeShellScriptBin "qutebrowser-gl" ''${nixglpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser "$@"'')
  (pkgs.writeShellScriptBin "kitty-gl" ''${nixglpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"'')

  aria
  bat
  curl
  direnv
  fd
  file
  fish
  fzf
  git-crypt
  htop
  imagemagick
  inxi
  jq
  killall
  lsd
  mdcat
  (nerdfonts.override { fonts = [ settings.font.name ]; })
  nnn
  openssl
  openvpn
  ripgrep
  rlwrap
  rnix-lsp
  tig
  universal-ctags
  unrar
  unzip
  wget
  ydotool
]
