{ pkgs, ... }:
let
  settings = import ../settings;
  nixglpkgs = (import (builtins.fetchTarball { url = "https://github.com/guibou/nixGL/archive/main.tar.gz"; }) { });
in
with pkgs; [
  nixglpkgs.nixGLIntel
  (pkgs.writeShellScriptBin "qutebrowser-gl" ''${nixglpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser "$@"'')
  (pkgs.writeShellScriptBin "kitty-gl" ''${nixglpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"'')
  (nerdfonts.override { fonts = [ settings.font.name ]; })
  (import ./git-ctags.nix { inherit pkgs; })

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
  nnn
  openssl
  openvpn
  qtpass
  ripgrep
  rlwrap
  rnix-lsp
  tig
  universal-ctags
  unrar
  unzip
  wget
  ydotool
  wl-clipboard
]
