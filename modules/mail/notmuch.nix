{ config
, lib
, pkgs
, ...
}:
let
  account = import ./account.nix;
in
{
  config = {
    programs.notmuch.enable = true;
    programs.notmuch.hooks.postNew = builtins.concatStringsSep "\n" ([
      "#!/usr/bin/env ${pkgs.bash}/bin/bash"
      "set -euo pipefail"
      (account.notmuchTag pkgs.notmuch "+github" "from:noreply@github.com OR from:notifications@github.com")
      (account.notmuchTag pkgs.notmuch "+gitlab" "from:gitlab@gitlab.binarapps.com")
      (account.notmuchTag pkgs.notmuch "-inbox" "tag:inbox and not tag:unread")
      (account.notmuchStripInbox pkgs.notmuch (lib.attrNames config.mail.accounts))
      (account.notmuchTag pkgs.notmuch "-account:*" "*")
    ] ++ lib.mapAttrsToList (k: v: account.notmuchSteps pkgs.notmuch k v.email) config.mail.accounts);
  };
}
