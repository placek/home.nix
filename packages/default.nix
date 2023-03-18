{ pkgs, glpkgs, ... }:
let
  settings = import ../settings;
in
with pkgs; [
  glpkgs.nixGLIntel
  (pkgs.writeShellScriptBin "qutebrowser-gl" ''${glpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser "$@"'')
  (pkgs.writeShellScriptBin "kitty-gl" ''${glpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"'')
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
