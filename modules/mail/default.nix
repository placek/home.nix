{ config
, pkgs
, ...
}:
{
  config = {
    home.file.mailcap = {
      enable = true;
      target = ".mailcap";
      text = ''
        text/html; ${pkgs.w3m}/bin/w3m -dump -o document_charset=%{charset} -o display_link_number=1 '%s'; nametemplate=%s.html; copiousoutput
      '';
    };

    programs.alot.enable = true;

    programs.notmuch = {
      enable = true;
      hooks.postNew = ''
        ${pkgs.notmuch}/bin/notmuch tag -inbox -- tag:inbox and not tag:unread
        ${pkgs.notmuch}/bin/notmuch tag +github -- from:noreply@github.com or from:notifications@github.com
        ${pkgs.notmuch}/bin/notmuch tag +gitlab -- from:gitlab@gitlab.binarapps.com
        ${pkgs.notmuch}/bin/notmuch tag -Inbox -- not folder:placzynski/Inbox and not folder:silquenarmo/Inbox and not folder:binarapps/Inbox and not folder:byron/Inbox and tag:Inbox
      '';
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;

    xdg.configFile."mbsync/postExec" = {
      text = ''
        #!${pkgs.stdenv.shell}
        ${pkgs.notmuch}/bin/notmuch new
      '';
      executable = true;
    };

    services.mbsync = {
      enable = true;
      postExec = "${config.xdg.configHome}/mbsync/postExec";
      frequency = "*:0/10";
    };

    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        silquenarmo = import ./accounts/silquenarmo.nix { inherit pkgs; };
        placzynski = import ./accounts/placzynski-pawel.nix { inherit pkgs; };
        binarapps = import ./accounts/p-placzynski-binarapps.nix { inherit pkgs; };
        byron = import ./accounts/pawel-placzynski-byron.nix { inherit pkgs; };
      };
    };
  };
}
