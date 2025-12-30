{ config
, pkgs
, ...
}:
{
  config = {
    programs.mbsync.enable = true;
    services.mbsync.enable = true;
    services.mbsync.postExec = "${pkgs.notmuch}/bin/notmuch new";
    services.mbsync.frequency = "*:0/1"; # every minute
  };
}
