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
      description = "Terminal executable.";
      readOnly = true;
    };
  };

  imports = [
    ./key-bindings.nix
    ./settings.nix
  ];

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

    programs.kitty.enable = true;
  };
}
