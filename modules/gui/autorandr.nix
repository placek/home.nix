{ config
, lib
, pkgs
, ...
}:
let
  fingerprint = {
    "eDP-1" = "00ffffffffffff0006af9b1000000000001b0104a5261578022425a85036b6260e50540000000101010101010101010101010101010166d000a0f0703e80302035007ed6100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe00423137335a414e30312e30200a0039";
    "DP-1-1" = "00ffffffffffff001ab32d08803200002017010380351e782a0ec5a555509e26125054a54b0081c081809500b300d1c0010101010101023a801871382d40582c4500132b2100001e000000fd00384c1e5211000a202020202020000000fc00423234542d37204c4544205047000000ff005956364b3031323932380a20200146020324744f909f85940413031201071602110615230907078301000067030c001000b02d023a80d072382d40102c9680132b21000018011d8018711c1620582c2500132b2100009e011d80d0721c1620102c2580132b2100009e011d00bc52d01e20b8285540132b2100001e8c0ad090204031200c405500132b2100001800ad";
  };
in
{
  config = {
    programs.autorandr.enable = true;
    services.autorandr.enable = true;
    programs.autorandr.hooks.postswitch = {
      notify = ''
        ${pkgs.libnotify}/bin/notify-send "Autorandr" $(${pkgs.autorandr}/bin/autorandr --current)
      '';
    };
    programs.autorandr.profiles = {
      work-dual = {
        inherit fingerprint;
        config = {
          "DP-1-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.00";
          };
          "eDP-1" = {
            enable = true;
            crtc = 1;
            primary = false;
            position = "1920x0";
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
      work = {
        inherit fingerprint;
        config = {
          "DP-1-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.00";
          };
          "eDP-1".enable = false;
        };
      };
    };

    home.packages = [ pkgs.arandr ];
  };
}
