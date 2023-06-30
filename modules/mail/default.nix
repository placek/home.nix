{ config
, pkgs
, ...
}:
{
  config = {
    xdg.desktopEntries.astroid = {
      name = "Astroid";
      genericName = "Astroid";
      type = "Application";
      exec = "astroid";
      terminal = false;
      icon = "claws-mail";
    };

    programs.astroid = {
      enable = true;
      externalEditor = ''
        ${config.terminalExec} ${config.editorExec} "+set ft=mail" "+set fileencoding=utf-8" "+set ff=unix" "+set enc=utf-8" "+set fo+=w" %1
      '';
      extraConfig = {
        startup.queries = {
          placzynski = "folder:placzynski/Inbox";
          silquenarmo = "folder:silquenarmo/Inbox";
          binarapps = "folder:binarapps/Inbox";
          byron = "folder:byron/Inbox";
          futurelearn = "folder:futurelearn/Inbox";
        };
      };
    };

    programs.notmuch = {
      enable = true;
      hooks.postNew = ''
        ${pkgs.notmuch}/bin/notmuch tag -inbox -- tag:inbox and not tag:unread
        ${pkgs.notmuch}/bin/notmuch tag +github -- from:noreply@github.com or from:notifications@github.com
        ${pkgs.notmuch}/bin/notmuch tag +gitlab -- from:gitlab@gitlab.binarapps.com
        ${pkgs.notmuch}/bin/notmuch tag -Inbox -- not folder:placzynski/Inbox and not folder:silquenarmo/Inbox and not folder:binarapps/Inbox and not folder:byron/Inbox and not folder:futurelearn/Inbox and tag:Inbox
      '';
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;

    xdg.configFile."mbsync/postExec" = {
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

    services.mbsync = {
      enable = true;
      postExec = "${config.xdg.configHome}/mbsync/postExec";
      frequency = "*:0/30";
    };

    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        silquenarmo = import ./accounts/silquenarmo.nix { inherit pkgs; };
        placzynski = import ./accounts/placzynski-pawel.nix { inherit pkgs; };
        binarapps = import ./accounts/p-placzynski-binarapps.nix { inherit pkgs; };
        futurelearn = import ./accounts/pawel-placzynski-futurelearn.nix { inherit pkgs; };
        byron = import ./accounts/pawel-placzynski-byron.nix { inherit pkgs; };
      };
    };
  };
}
