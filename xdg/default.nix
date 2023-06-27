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
      unread=''$(${pkgs.notmuch}/bin/notmuch search --format=json tag:unread | ${pkgs.jq}/bin/jq "[.[].matched] | add // 0")
      if [ ''${unread} -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -a astroid "Mail" "''${unread} new messages!"
      fi
    '';
    executable = true;
  };

  desktopEntries = {
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
