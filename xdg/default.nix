{ config, pkgs, settings, ... }:
let
  papirusPath = "${pkgs.papirus-icon-theme}/share/icons/ePapirus-Dark/128x128";
in
{
  enable = true;

  systemDirs.data = [ "${settings.dirs.home}/.nix-profile/share" ];

  desktopEntries = {
    qtpass = {
      name = "QtPass";
      genericName = "QtPass";
      type = "Application";
      exec = "qtpass";
      terminal = false;
      icon = "${papirusPath}/apps/qtpass-icon.svg";
    };
  };
}
