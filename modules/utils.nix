{ config, pkgs, ... }:
let
  sources = import ../home.lock.nix;
  settings = import ../settings;

  custom-nerdfonts = pkgs.nerdfonts.override { fonts = [ settings.font.name ]; };
  speak = pkgs.writeShellScriptBin "speak" ''
    #!/usr/bin/env bash

    OUTPUT=unset
    LANGUAGE="en"

    usage()
    {
      echo "Usage: speak [ -o | --stdout ] [ -l | --lang LANGUAGE ] TEXT"
      exit 2
    }

    PARSED_ARGUMENTS=$(getopt -a -n speak -o ol: --long stdout,lang: -- "$@")
    VALID_ARGUMENTS=$?
    if [ "$VALID_ARGUMENTS" != "0" ]; then
      usage
    fi

    eval set -- "$PARSED_ARGUMENTS"
    while :
    do
      case "$1" in
        -o | --stdout)  OUTPUT=1      ; shift   ;;
        -l | --lang)    LANGUAGE="$2" ; shift 2 ;;
        --)             shift; break ;;
        *)              echo "Unexpected option: $1 - this should not happen."
                        usage ;;
      esac
    done
    TEXT="$@"

    if [ "$OUTPUT" == "1" ]; then
      ${pkgs.python39Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT"
    else
      ${pkgs.python39Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT" | ${pkgs.sox}/bin/play -q -t mp3 -
    fi
  '';
in
{
  programs.aria2.enable = true;
  programs.broot.enable = true;
  programs.direnv.enable = true;
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.lsd.enable = true;
  programs.nix-index.enable = true;
  programs.nnn.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  home.packages = with pkgs; [
    sources.glpkgs.nixGLIntel

    custom-nerdfonts
    speak

    ubuntu_font_family
    google-fonts
    font-awesome

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
  ];
}
