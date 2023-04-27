{ config, pkgs, settings, ... }:
let
  papirusPath = "${pkgs.papirus-icon-theme}/share/icons/ePapirus-Dark/128x128";
in
{
  enable = true;

  systemDirs.data = [ "${settings.dirs.home}/.nix-profile/share" ];

  mimeApps.defaultApplications = {
    "text/html" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/http" = [ "qutebrowser.desktop" ];
    "x-scheme-handler/https" = [ "qutebrowser.desktop" ];
  };

  configFile."mbsync/postExec" = {
    text = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.notmuch}/bin/notmuch new
      ${pkgs.libnotify}/bin/notify-send "Mail" "Synced!"
    '';
    executable = true;
  };

  desktopEntries = {
    kitty = {
      name = "Terminal";
      genericName = "Terminal";
      type = "Application";
      exec = "kitty-gl";
      terminal = false;
      icon = "${papirusPath}/apps/terminal.svg";
    };

    qtpass = {
      name = "QtPass";
      genericName = "QtPass";
      type = "Application";
      exec = "qtpass";
      terminal = false;
      icon = "${papirusPath}/apps/qtpass-icon.svg";
    };

    astroid = {
      name = "Astroid";
      genericName = "Astroid";
      type = "Application";
      exec = "astroid";
      terminal = false;
      icon = "${papirusPath}/apps/claws-mail.svg";
    };
  };
}
