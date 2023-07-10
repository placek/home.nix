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
      font.name = config.gui.font.name;
      font.size = config.gui.font.size;
      keybindings = import ./key-bindings.nix;
      settings = import ./settings.nix { inherit (config) shellExec editorExec; inherit (config.gui) theme; };
      extraConfig = builtins.readFile ./extraConfig;
    };
  };
}
