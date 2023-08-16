{ config
, lib
, pkgs
, ...
}:
let
  statuses = pkgs.writeShellScriptBin "statuses" ''
    #!${pkgs.stdenv.shell}

    # right separator
    printf " "

    # playerctl status
    case $(${pkgs.playerctl}/bin/playerctl status) in
      Playing) printf "<action=\`${pkgs.playerctl}/bin/playerctl pause\` button=1><fn=1>\\uf04c</fn> $(${pkgs.playerctl}/bin/playerctl metadata --format "{{ trunc(artist,20) }}: {{ trunc(title,30) }}")</action> " ;;
      Paused)  printf "<action=\`${pkgs.playerctl}/bin/playerctl play\` button=1><fn=1>\\uf04b</fn> $(${pkgs.playerctl}/bin/playerctl metadata --format "{{ trunc(artist,20) }}: {{ trunc(title,30) }}") </action>" ;;
    esac

    # dunst notifications status
    if [ $(${pkgs.dunst}/bin/dunstctl is-paused) == "true" ]; then
      count=$(${pkgs.dunst}/bin/dunstctl count waiting)
      [ "$count" != "0" ] && printf "<action=\`${pkgs.playerctl}/bin/playerctl pause\` button=1><fc=${config.gui.theme.base01}><fn=1>\\uf0f3</fn> $count</fc></action> "
    else
      count=$(${pkgs.dunst}/bin/dunstctl count displayed)
      [ "$count" != "0" ] && printf "<fn=1>\\uf0f3</fn> $count "
    fi

    exit 0
  '';
in
{
  options = with lib; {
    gui.showWiFi = mkEnableOption "Show WiFi status in xmobar.";
    gui.showBattery = mkEnableOption "Show battery status in xmobar.";
  };

  config = {
    home.packages = [ statuses ];
    programs.xmobar.enable = true;
    programs.xmobar.extraConfig = ''
      Config { font            = "${config.gui.font.name} ${builtins.toString config.gui.font.size}"
             , additionalFonts = [ "Font Awesome 6 Free ${builtins.toString config.gui.font.size}" ]
             , bgColor         = "${config.gui.theme.base00}"
             , fgColor         = "${config.gui.theme.base0F}"
             , position        = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
             , lowerOnStart    = True
             , sepChar         = "%"
             , alignSep        = "}{"
             , template        =
             "%UnsafeStdinReader%}{%mail%%statuses%%multicpu%%memory%%disku%%default:Capture%%default:Master%${if config.gui.showBattery then "%battery%" else ""}%dynnetwork%${if config.gui.showWiFi then "%wlan0wi%" else ""}%EPLL%%date%"
             , commands        = [ Run NotmuchMail "mail"         [ MailItem "\xf0e0  " "" "tag:unread"
                                                                  ] 50

                                 , Run ComX "statuses"            [] " " "${statuses}/bin/statuses" 10

                                 , Run MultiCpu                   [ "-t", "\xE0B3 <fn=1>\xf2db</fn> <vbar> "
                                                                  , "-L", "30", "-H", "70"
                                                                  , "-l", "${config.gui.theme.base02}"
                                                                  , "-n", "${config.gui.theme.base03}"
                                                                  , "-h", "${config.gui.theme.base01}"
                                                                  ] 10

                                 , Run Memory                     [ "-t", "\xE0B3 <fn=1>\xf538</fn> <usedvbar> "
                                                                  , "-L", "30", "-H", "70"
                                                                  , "-l", "${config.gui.theme.base02}"
                                                                  , "-n", "${config.gui.theme.base03}"
                                                                  , "-h", "${config.gui.theme.base01}"
                                                                  ] 10

                                 , Run DiskU                      [ ("/", "\xE0B3 <fn=1>\xf0a0</fn> <usedvbar> ") ]
                                                                  [ "-L", "30", "-H", "70"
                                                                  , "-l", "${config.gui.theme.base02}"
                                                                  , "-n", "${config.gui.theme.base03}"
                                                                  , "-h", "${config.gui.theme.base01}"
                                                                  ] 100

                                 , Run Volume "default" "Capture" [ "-t", "\xE0B3 <fn=1><status></fn> "
                                                                  , "--"
                                                                  , "-C", "${config.gui.theme.base0F}"
                                                                  , "-c", "${config.gui.theme.base0F}"
                                                                  , "-O", "\xf130", "-o", "\xf131"
                                                                  ] 10

                                 , Run Volume "default" "Master"  [ "-t", "<fn=1><status></fn> <volumevbar> "
                                                                  , "--"
                                                                  , "-C", "${config.gui.theme.base0F}"
                                                                  , "-c", "${config.gui.theme.base0F}"
                                                                  , "-O", "\xf028", "-o", "\xf6a9"
                                                                  ] 10

                                 , Run Battery                    [ "-t", "\xE0B3 <acstatus> "
                                                                  , "--"
                                                                  , "-O", "<fn=1>\xf0e7</fn> <leftvbar>"
                                                                  , "-i", "<fn=1>\xf0e7</fn> <leftvbar>"
                                                                  , "-o", "<fn=1>\xf242</fn> <timeleft> <leftvbar>"
                                                                  , "-a", "notify-send -u critical 'battery' 'below 10%'", "-A", "10"
                                                                  ] 50

                                 , Run DynNetwork                 [ "-t", "<fc=${config.gui.theme.base08},${config.gui.theme.base00}>\xE0B2</fc><fc=${config.gui.theme.base0F},${config.gui.theme.base08}> <dev> <rx>↓↑<tx> </fc>"
                                                                  ] 10

                                 , Run Wireless "wlan0"           [ "-t", "<fc=${config.gui.theme.base0F},${config.gui.theme.base08}>\xE0B3 <ssid> <qualityvbar> </fc>"
                                                                  ] 10

                                 , Run Date                       "<fc=${config.gui.theme.base00},${config.gui.theme.base07}> \xE0B3 %a \xE0B3 %H:%M \xE0B3 %d.%m.%Y </fc>" "date" 10

                                 , Run WeatherX "EPLL"            [ ("clear",                   "clear")
                                                                  , ("sunny",                   "clear")
                                                                  , ("fair",                    "clear")
                                                                  , ("mostly clear",            "cloudy")
                                                                  , ("mostly sunny",            "cloudy")
                                                                  , ("partly sunny",            "cloudy")
                                                                  , ("partly cloudy",           "cloudy")
                                                                  , ("cloudy",                  "overcast")
                                                                  , ("obscured",                "overcast")
                                                                  , ("overcast",                "overcast")
                                                                  , ("mostly cloudy",           "overcast")
                                                                  , ("considerable cloudiness", "overcast")]
                                                                  [ "-t",
                                                                  "<fc=${config.gui.theme.base07},${config.gui.theme.base08}>\xE0B2</fc><fc=${config.gui.theme.base00},${config.gui.theme.base07}> <skyConditionS> <tempC>\x2103 <rh>% <windKnots>kn <windCardinal></fc>" ]
                                                                  18000

                                 , Run UnsafeStdinReader
                                 ]
             }
    '';
  };
}
