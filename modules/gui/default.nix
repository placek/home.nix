{ config
, lib
, pkgs
, ...
}:
let
  mySlack = pkgs.writeShellScriptBin "my-slack" ''
    hyprctl dispatch exec "[workspace 2 silent] ${pkgs.slack}/bin/slack"
  '';

  mySpotify = pkgs.writeShellScriptBin "my-spotify" ''
    hyprctl dispatch exec "[workspace 3 silent] ${pkgs.spotify}/bin/spotify"
  '';

  myQcad = pkgs.writeShellScriptBin "my-qcad" ''
    exec env QT_QPA_PLATFORM=xcb ${pkgs.qcad}/bin/qcad "$@"
  '';
in
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

    menuExec = mkOption {
      type = types.str;
      default = "${pkgs.xprompt}/bin/xprompt";
      description = "GUI menu executable.";
      readOnly = true;
    };
  };

  imports = [
    ./fonts.nix

    ./clipcat.nix
    ./dunst.nix
    ./hyprland
    ./mpv.nix
    ./zathura.nix

    ./games
  ];

  config = {
#     programs.discord.enable = true;

    home.packages = with pkgs; [
      libnotify
      xf86_input_wacom

      gimp
      inkscape-with-extensions
      kicad
      librecad
      libreoffice
      lilypond
      musescore
      qimgv
    ];

    xdg.desktopEntries =  {
      my-slack = {
        name = "Slack";
        genericName = "slack";
        type = "Application";
        exec = "${mySlack}/bin/my-slack";
        icon = "slack";
        terminal = false;
      };

      my-spotify = {
        name = "Spotify";
        genericName = "spotify";
        type = "Application";
        exec = "${mySpotify}/bin/my-spotify";
        icon = "spotify";
        terminal = false;
      };

      my-qcad = {
        name = "QCAD";
        genericName = "qcad";
        type = "Application";
        exec = "${myQcad}/bin/my-qcad %F";
        icon = "qcad";
        terminal = false;
      };
    };
  };
}
