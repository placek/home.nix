{ config, pkgs, ... }:
{
  gpg-agent = import ./gpg-agent;
  mbsync = {
    enable = true;
    preExec = "${config.xdg.configHome}/mbsync/preExec";
    postExec = "${config.xdg.configHome}/mbsync/postExec";
    frequency = "*:0/30";
  };
}
