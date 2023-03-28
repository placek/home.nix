{ pkgs, glpkgs, ... }:
let
  settings = import ../settings;
in
with pkgs; [
  glpkgs.nixGLIntel
  (writeShellScriptBin "qutebrowser-gl" ''${glpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser "$@"'')
  (writeShellScriptBin "kitty-gl" ''${glpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"'')
  (writeShellScriptBin "xpass" ''
    case "$1" in
      a*)
        entry=$(find -L ${settings.key.store} -name "*.gpg" -type "f" -printf "%P\n" | sed 's/\.gpg$//' | xprompt -c)
        pass_output=$(pass "$entry" | sed '1s/^/password: /' | sed 's/^otpauth:/otp: &/')
        password=$(echo "$pass_output" | yq ".password")
        user=$(echo "$pass_output" | yq ".user")
        pass otp --clip "$entry"
        ydotool type "$user\t$password"
        ;;
      u*)
        entry=$(find -L ${settings.key.store} -name "*.gpg" -type "f" -printf "%P\n" | sed 's/\.gpg$//' | xprompt -c)
        pass_output=$(pass "$entry" | sed '1s/^/password: /' | sed 's/^otpauth:/otp: &/')
        user=$(echo "$pass_output" | yq ".user")
        ydotool type "$user"
        ;;
      p*)
        entry=$(find -L ${settings.key.store} -name "*.gpg" -type "f" -printf "%P\n" | sed 's/\.gpg$//' | xprompt -c)
        pass_output=$(pass "$entry" | sed '1s/^/password: /' | sed 's/^otpauth:/otp: &/')
        password=$(echo "$pass_output" | yq ".password")
        pass otp --clip "$entry"
        ydotool type "$password"
        ;;
      o*)
        entry=$(find -L ${settings.key.store} -name "*.gpg" -type "f" -printf "%P\n" | sed 's/\.gpg$//' | xprompt -c)
        pass otp --clip "$entry"
        ;;
      *)
        >&2 echo "xpass help|autocpmplete|user|password|otp"
        exit 1
        ;;
    esac
  '')
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
  yq
  wl-clipboard
]
