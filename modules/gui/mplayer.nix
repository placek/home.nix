{ config
, lib
, pkgs
, ...
}:
{
  config = {
    home.packages = with pkgs; [ mplayer ];
    xdg.mimeApps.defaultApplications = {
      "audio/*" = [ "mplayer.desktop" ];
      "video/*" = [ "mplayer.desktop" ];
    };
  };
}
