{ config
, pkgs
, ...
}:
let
  email = "pawel@kpitech.pl";
  identity = "kpitech"
  key = "f";
  notmuchSteps = [
    "tag +account:${identity} -- 'path:${identity}/**'"
    "tag +account:${identity} -- '(to:${email} OR from:${email})'"
  ];
in
{
  config.accounts.email.accounts."${identity}" = {
    address = email;
    userName = email;
    realName = "Paweł Placzyński";
    passwordCommand = "${pkgs.pass}/bin/pass MAIL/${email}";
    imap.host = "imap.gmail.com";
    smtp.host = "smtp.gmail.com";
    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" ];
      extraConfig = {
        channel = {
          Sync = "All";
        };
        account = {
          Timeout = 120;
          PipelineDepth = 1;
        };
      };
    };
    notmuch.enable = true;
    astroid.enable = true;
    msmtp.enable = true;
  };

  config.programs.alot.bindings.search."${key}" = "search account:${identity}";
}
