{ pkgs
, ...
}:
{
  address = "pawel.placzynski@byron.network";
  userName = "pawel.placzynski@byron.network";
  realName = "Paweł Placzyński";
  passwordCommand = "${pkgs.pass}/bin/pass MAIL/pawel.placzynski@byron.network";
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
}
