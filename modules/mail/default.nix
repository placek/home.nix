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
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        set -euo pipefail

        nm=${pkgs.notmuch}/bin/notmuch

        $nm tag -inbox -- tag:inbox and not tag:unread
        $nm tag +github -- from:noreply@github.com or from:notifications@github.com
        $nm tag +gitlab -- from:gitlab@gitlab.binarapps.com
        # --- No Inbox ---
        $nm tag -Inbox -- not folder:placzynski/Inbox and not folder:silquenarmo/Inbox and not folder:binarapps/Inbox and not folder:byron/Inbox and tag:Inbox

        # --- Account tagging ---
        # Clear all previous account:* tags (safe: re-compute right after)
        $nm tag -account:* -- '*'

        $nm tag +account:silquenarmo -- 'path:silquenarmo/**'
        $nm tag +account:placzynski  -- 'path:placzynski/**'
        $nm tag +account:binarapps   -- 'path:binarapps/**'

        $nm tag +account:silquenarmo -- '(to:silquenarmo@gmail.com OR from:silquenarmo@gmail.com)'
        $nm tag +account:placzynski  -- '(to:placzynski.pawel@gmail.com OR from:placzynski.pawel@gmail.com)'
        $nm tag +account:binarapps   -- '(to:p.placzynski@binarapps.com OR from:p.placzynski@binarapps.com)'
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
      frequency = "*:0/5"; # every 5 minutes
    };

    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        silquenarmo = import ./accounts/silquenarmo.nix { inherit pkgs; };
        placzynski = import ./accounts/placzynski-pawel.nix { inherit pkgs; };
        binarapps = import ./accounts/p-placzynski-binarapps.nix { inherit pkgs; };
      };
    };
  };
}
