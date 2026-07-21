{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    terminalExec = mkOption {
      type = types.str;
      default = "${config.programs.kitty.package}/bin/kitty";
      description = "Terminal executable.";
      readOnly = true;
    };
  };

  imports = [
    ./key-bindings.nix
    ./settings.nix
  ];

  config = {
    # kitty itself is installed by programs.kitty.enable below.

    xdg.desktopEntries.kitty = {
      name = "Terminal";
      genericName = "Terminal";
      type = "Application";
      exec = config.terminalExec;
      terminal = false;
      icon = "terminal";
    };

    programs.bash.shellAliases.icat = "kitty +kitten icat";
    programs.fish.shellAliases.icat = "kitty +kitten icat";
    programs.kitty.shellIntegration.enableBashIntegration = true;
    programs.kitty.shellIntegration.enableFishIntegration = true;

    programs.kitty.enable = true;
  };
}
