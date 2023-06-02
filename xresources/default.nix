{ settings
, ...
}:
{
  properties = with settings.colors; {
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
    "xprompt.font" = settings.font.fullName;
    "xprompt.geometry" = "0x32+0+0";
  };
}
