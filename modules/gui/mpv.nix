{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.mpv.enable = true;
    programs.mpv.scripts = [ pkgs.mpvScripts.mpris ];
    programs.mpv.config = {
      profile = "gpu-hq";
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
    xdg.mimeApps.defaultApplications = {
      "audio/*" = [ "mpv.desktop" ];
      "video/*" = [ "mpv.desktop" ];
      "audio/x-opus+ogg" = [ "mpv.desktop" ];
    };
  };
}
