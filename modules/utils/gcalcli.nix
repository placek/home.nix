{ config
, lib
, pkgs
, ...
}:
{
  home.packages = [ pkgs.gcalcli ];

  xdg.configFile."gcalcli/config.toml".text = ''
    [output]
    week-start = "monday"
  '';
}
