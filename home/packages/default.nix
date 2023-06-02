{ pkgs, glpkgs, settings, ... }:
let
  git-ctags = import ./git-ctags.nix { inherit pkgs; };
  qutebrowser-gl = import ./qutebrowser-gl.nix { inherit pkgs glpkgs; };
  kitty-gl = import ./kitty-gl.nix { inherit pkgs glpkgs; };
  custom-nerdfonts = import ./custom-nerdfonts.nix { inherit pkgs settings; };
  speak = import ./speak.nix { inherit pkgs; };
in
with pkgs; [
  glpkgs.nixGLIntel

  custom-nerdfonts
  git-ctags
  kitty-gl
  qutebrowser-gl
  speak

  ubuntu_font_family google-fonts font-awesome

  curl
  fd
  file
  git-crypt
  imagemagick
  killall
  libinput
  xf86_input_wacom
  mdcat
  openssl
  openvpn
  qtpass
  ripgrep
  rlwrap
  rnix-lsp
  sox
  universal-ctags
  unrar
  unzip
  wget
  wl-clipboard
  xprompt
  yq
]
