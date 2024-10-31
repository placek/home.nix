{ config
, lib
, pkgs
, ...
}:
let
  displays = import ./known_displays.nix;
in
{
  config.programs.autorandr.profiles = {
    home-dual = {
      fingerprint = { inherit (displays) DVI-I-2-1 DVI-I-3-2; };
      config = {
        DVI-I-2-1 = {
          enable = true;
          primary = false;
          position = "1920x0";
          mode = "1920x1080";
          rate = "60.00";
        };
        DVI-I-3-2 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1080";
          rate = "60.00";
        };
      };
    };
    home-triple = {
      fingerprint = { inherit (displays) DVI-I-2-1 DVI-I-3-2 eDP-1; };
      config = {
        DVI-I-2-1 = {
          enable = true;
          primary = false;
          position = "1920x0";
          mode = "1920x1080";
          rate = "60.00";
        };
        DVI-I-3-2 = {
          enable = true;
          primary = true;
          position = "0x0";
          mode = "1920x1080";
          rate = "60.00";
        };
        eDP-1 = {
          enable = true;
          primary = false;
          position = "0x0";
          mode = "1920x1080";
          rate = "60.00";
        };
      };
    };
  };
}
