{ config, ... }:
{
  enable = true;
  preExec = "${config.xdg.configHome}/mbsync/preExec";
  postExec = "${config.xdg.configHome}/mbsync/postExec";
  frequency = "*:0/30";
}
