{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    gui.theme = mkOption {
      type = with types; submodule {
        options = {
          base00 = mkOption { type = str; };
          base01 = mkOption { type = str; };
          base02 = mkOption { type = str; };
          base03 = mkOption { type = str; };
          base04 = mkOption { type = str; };
          base05 = mkOption { type = str; };
          base06 = mkOption { type = str; };
          base07 = mkOption { type = str; };
          base08 = mkOption { type = str; };
          base09 = mkOption { type = str; };
          base0A = mkOption { type = str; };
          base0B = mkOption { type = str; };
          base0C = mkOption { type = str; };
          base0D = mkOption { type = str; };
          base0E = mkOption { type = str; };
          base0F = mkOption { type = str; };
        };
      };
      description = mdDoc "A color scheme.";
    };

    gui.border.size = mkOption {
      type = types.int;
      default = 4;
      description = mdDoc "A border size.";
    };

    gui.wallpaper = mkOption {
      type = types.path;
      default = ./wallpaper.jpg;
      description = mdDoc "A wallpaper.";
      readOnly = true;
    };

    menuExec = mkOption {
      type = types.str;
      default = "${pkgs.xprompt}/bin/xprompt";
      description = mdDoc "GUI menu executable.";
      readOnly = true;
    };
  };

  imports = [
    ./fonts.nix

    ./dunst.nix
    ./feh.nix
    ./xmobar.nix
    ./mpv.nix
    ./zathura.nix

    ./xmonad
  ];

  config = {
    home.packages = with pkgs; [
      arandr
      libnotify
      shotwell
      xclip
      xf86_input_wacom

      arduino
      blender
      discord
      dzen2
      firefox
      gimp
      inkscape-with-extensions
      kicad
      librecad
      qcad
      lilypond
      qcad
      slack
      steam

      (import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/8ad5e8132c5dcf977e308e7bf5517cc6cc0bf7d8.tar.gz";
      }) {}).spotify
    ];
  };
}
