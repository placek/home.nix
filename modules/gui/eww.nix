{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.eww ];

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww bar";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
      ExecStartPost = "${pkgs.eww}/bin/eww open bar";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}

