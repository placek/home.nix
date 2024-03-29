{ pkgs
, ...
}:
{
  primary = true;
  address = "placzynski.pawel@gmail.com";
  userName = "placzynski.pawel@gmail.com";
  realName = "Paweł Placzyński";
  passwordCommand = "${pkgs.pass}/bin/pass MAIL/placzynski.pawel@gmail.com";
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

