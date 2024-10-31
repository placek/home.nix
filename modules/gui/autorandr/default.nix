{ config
, lib
, pkgs
, ...
}:
{
  imports = [
    ./profiles.nix
  ];

  config = {
    programs.autorandr.enable = true;
    programs.autorandr.hooks.postswitch.notify = ''
      ${pkgs.libnotify}/bin/notify-send "Display profile changed" $(${pkgs.autorandr}/bin/autorandr --detected)
    '';
    home.packages = [ pkgs.arandr ];
  };
}
