{ config
, lib
, ...
}:
{
  options.gui = with lib; {
    theme = mkOption {
      type = with types; submodule {
        options = {
          base00 = mkOption { type = str; };
          base01 = mkOption { type = str; };
          base02 = mkOption { type = str; };
          base03 = mkOption { type = str; };
          base04 = mkOption { type = str; };
          base05 = mkOption { type = str; };
          base06 = mkOption { type = str; };
          base07 = mkOption { type = str; };
          base08 = mkOption { type = str; };
          base09 = mkOption { type = str; };
          base0A = mkOption { type = str; };
          base0B = mkOption { type = str; };
          base0C = mkOption { type = str; };
          base0D = mkOption { type = str; };
          base0E = mkOption { type = str; };
          base0F = mkOption { type = str; };
        };
      };
      description = mdDoc "A color scheme.";
    };

    font.name = mkOption {
      type = types.str;
      example = "Iosevka Nerd Font";
      description = mdDoc "A name of TTF font.";
    };

    font.size = mkOption {
      type = types.int;
      example = 12;
      description = mdDoc "A font size.";
    };
  };

  config = {
    xresources = {
      properties = with config.gui.theme; {
        "*foreground" = base0F;
        "*background" = base00;
        "*cursorColor" = base0F;
        "*color0" = base00;
        "*color1" = base01;
        "*color2" = base02;
        "*color3" = base03;
        "*color4" = base04;
        "*color5" = base05;
        "*color6" = base06;
        "*color7" = base07;
        "*color8" = base08;
        "*color9" = base09;
        "*color10" = base0A;
        "*color11" = base0B;
        "*color12" = base0C;
        "*color13" = base0D;
        "*color14" = base0E;
        "*color15" = base0F;

        "*termName" = "xterm-256color";

        "Xft.dpi" = 96;
        "Xft.autohint" = true;
        "Xft.lcdfilter" = "lcdfilter";
        "Xft.hintstyle" = "hintslight";
        "Xft.hinting" = true;
        "Xft.antialias" = true;
        "Xft.rgba" = "rgb";
        "xprompt.font" = config.gui.font.name;
        "xprompt.geometry" = "0x32+0+0";
      };
    };
  };
}
