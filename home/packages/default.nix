{ pkgs, glpkgs, settings, ... }:
let
  custom-nerdfonts = import ./custom-nerdfonts.nix { inherit pkgs settings; };
  speak = import ./speak.nix { inherit pkgs; };
in
with pkgs; [
  glpkgs.nixGLIntel

  custom-nerdfonts
  speak

  ubuntu_font_family google-fonts font-awesome

  curl
  file
  imagemagick
  killall
  libinput
  xf86_input_wacom
  mdcat
  openssl
  openvpn
  qtpass
  rlwrap
  rnix-lsp
  sox
  unrar
  unzip
  wget
  wl-clipboard
  yq
]
