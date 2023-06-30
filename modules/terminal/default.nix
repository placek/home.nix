{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  kitty-gl = import ./kitty-gl.nix { inherit (sources) pkgs glpkgs; };
in
{
  options = with lib; {
    terminalExec = mkOption {
      type = types.str;
      default = "${kitty-gl}/bin/kitty-gl";
      description = mdDoc "Terminal executable.";
      readOnly = true;
    };

    terminal.theme = mkOption { # TODO make generalization over it's type
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

    font.name = mkOption {
      type = types.str;
      default = "Iosevka Nerd Font";
      example = "Iosevka Nerd Font";
      description = mdDoc "A name of TTF font.";
    };

    font.size = mkOption {
      type = types.int;
      default = 12;
      example = 12;
      description = mdDoc "A font size.";
    };
  };

  config = {
    home.packages = [
      kitty-gl
    ];

    xdg.desktopEntries.kitty = {
      name = "Terminal";
      genericName = "Terminal";
      type = "Application";
      exec = "kitty-gl";
      terminal = false;
      icon = "terminal";
    };

    programs.fish.shellAliases.icat = "kitty +kitten icat";

    programs.kitty = {
      enable = true;
      font.name = config.font.name;
      font.size = config.font.size;
      keybindings = import ./key-bindings.nix;
      settings = import ./settings.nix { inherit (config) shellExec editorExec; theme = config.terminal.theme; };
      extraConfig = builtins.readFile ./extraConfig;
    };
  };
}
