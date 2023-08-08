{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    terminalExec = mkOption {
      type = types.str;
      default = "${pkgs.kitty}/bin/kitty";
      description = mdDoc "Terminal executable.";
      readOnly = true;
    };
  };

  config = {
    home.packages = [ pkgs.kitty ];

    xdg.desktopEntries.kitty = {
      name = "Terminal";
      genericName = "Terminal";
      type = "Application";
      exec = config.terminalExec;
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
