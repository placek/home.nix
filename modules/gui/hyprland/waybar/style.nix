{ config
, ...
}:
let
  hexToRgba = hex: alpha:
    let
      toLower = s: builtins.replaceStrings ["A" "B" "C" "D" "E" "F"] ["a" "b" "c" "d" "e" "f"] s;
      stripHash = s:
        if builtins.substring 0 1 s == "#"
        then builtins.substring 1 (builtins.stringLength s - 1) s
        else s;

      s0 = stripHash (toLower hex);
      s  = if builtins.stringLength s0 == 3 then
             "${builtins.substring 0 1 s0}${builtins.substring 0 1 s0}" +
             "${builtins.substring 1 1 s0}${builtins.substring 1 1 s0}" +
             "${builtins.substring 2 1 s0}${builtins.substring 2 1 s0}"
           else s0;

      pair = i: builtins.substring i 2 s;
      hexDigits = {
        "0"=0; "1"=1; "2"=2; "3"=3; "4"=4; "5"=5; "6"=6; "7"=7; "8"=8; "9"=9;
        "a"=10; "b"=11; "c"=12; "d"=13; "e"=14; "f"=15;
      };
      digit = c: hexDigits.${c};
      hexPairToInt = p: digit (builtins.substring 0 1 p) * 16 + digit (builtins.substring 1 1 p);

      r = hexPairToInt (pair 0);
      g = hexPairToInt (pair 2);
      b = hexPairToInt (pair 4);
    in
      "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";

  normal_color = config.gui.theme.base07;
  dim_color = config.gui.theme.base08;
  dark_color = config.gui.theme.base00;
  hover_color = config.gui.theme.base0F;
  accent_color = config.gui.theme.base03;

  border_size = builtins.toString config.gui.border.size;
in
''
  * {
    font-family: ${config.gui.font.name}, "Font Awesome 6 Free", "Font Awesome 6 Free Solid";
    font-weight: bold;
    font-size: 14px;
    color: ${normal_color};
  }

  window#waybar {
    background: ${hexToRgba dark_color 0.6};
    border: none;
    margin: 0px;
  }

  #cpu,
  #custom-gpu,
  #memory,
  #disk,
  #network,
  #mpris,
  #pulseaudio,
  #custom-notmuch,
  #custom-weather,
  #clock {
    padding: ${border_size}px ${border_size}px;
    margin: 0px;
    border-width: 0px;
    border-radius: 0px;
  }

  #clock {
    color: ${hover_color};
  }

  #network:hover,
  #disk:hover,
  #battery:hover,
  #pulseaudio:hover,
  #custom-temperature:hover,
  #memory:hover,
  #cpu:hover,
  #mpris:hover,
  #custom-gpu:hover,
  #custom-notmuch:hover,
  #custom-weather:hover,
  #clock:hover {
    background-color: ${dim_color};
    color: ${hover_color};
  }

  #workspaces button {
    padding: ${border_size}px ${builtins.toString (config.gui.border.size * 3)}px;
    margin: 0px;
    border-width: 0px;
    border-top: ${border_size}px solid ${dark_color};
    border-radius: 0px;
  }

  window#waybar #workspaces button * {
    color: ${hover_color};
  }

  #workspaces button.visible {
    border-top: ${border_size}px solid ${dim_color};
  }

  #workspaces button.active {
    border-top: ${border_size}px solid ${accent_color};
  }

  window#waybar #workspaces button:hover {
    background: ${dim_color};
    border-top: ${border_size}px solid ${dim_color};
    background-image: none;
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button:hover * {
    color: ${hover_color};
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button.active:hover {
    border-top: ${border_size}px solid ${accent_color};
    box-shadow: none;
    text-shadow: none;
    outline: none;
  }

  window#waybar #workspaces button:hover > * {
    background: transparent;
    box-shadow: none;
    text-shadow: none;
    outline: none;
    color: ${hover_color};
  }

  tooltip {
    background: ${dark_color};
    padding: ${border_size}px;
    border-width: 0px;
    border-radius: 0px;
    box-shadow: none;
    text-shadow: none;
    outline: none;
    font-size: 14px;
    border: ${border_size}px solid ${dim_color};
    margin: 0px;
  }
''
