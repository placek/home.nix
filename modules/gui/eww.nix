{ config, pkgs, ... }:
{
  config = {
    home.packages = [ pkgs.eww ];
    xdg.configFile."eww/bar.yuck".text = ''
      (defwidget bar []
        (box :class "bar" (label :text "eww")))
    '';
    systemd.user.services.eww = {
      Unit.Description = "eww bar";
      Service = {
        ExecStart = "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
