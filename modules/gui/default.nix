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
      description = "A color scheme.";
    };

    gui.border.size = mkOption {
      type = types.int;
      default = 4;
      description = "A border size.";
    };

    gui.wallpaper = mkOption {
      type = types.path;
      default = ./wallpaper.jpg;
      description = "A wallpaper.";
      readOnly = true;
    };

    menuExec = mkOption {
      type = types.str;
      default = "${pkgs.xprompt}/bin/xprompt";
      description = "GUI menu executable.";
      readOnly = true;
    };
  };

  imports = [
    ./fonts.nix

    ./autorandr
    ./dunst.nix
    ./feh.nix
    ./eww.nix
    ./mpv.nix
    ./zathura.nix

    ./hyprland.nix
    ./games.nix
  ];

  config = {
    home.packages = with pkgs; [
      (pkgs.writeShellScriptBin "wallpaper" "feh --bg-fill '${config.gui.wallpaper}'")

      libnotify
      xf86_input_wacom

      discord
      gimp
      (import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/882842d2a908700540d206baa79efb922ac1c33d.tar.gz"; }) {}).inkscape-with-extensions
      kicad
      librecad
      libreoffice
      lilypond
      musescore
      qcad
      slack
      spotify
    ];
  };
}
