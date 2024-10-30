{ config
, lib
, pkgs
, ...
}:
let
  displays = import ./known_displays.nix;
in
{
  config = {
    programs.autorandr.enable = true;
    services.autorandr.enable = true;
    programs.autorandr.hooks.postswitch.notify = ''
      ${pkgs.libnotify}/bin/notify-send "Display profile changed" $(${pkgs.autorandr}/bin/autorandr --detected)
    '';
    programs.autorandr.profiles = {
      home-dual = {
        inherit (displays.work) fingerprint;
        config = {
          "DVI-I-2-1" = {
            enable = true;
            primary = false;
            position = "1920x0";
            mode = "1920x1080";
            rate = "60.00";
          };
          "DVI-I-3-2" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };

    home.packages = [ pkgs.arandr ];
  };
}
