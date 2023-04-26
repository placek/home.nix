{ config, ... }:
{
  enable = true;
  postExec = "${config.xdg.configHome}/mbsync/postExec";
  frequency = "*:0/30";
}
