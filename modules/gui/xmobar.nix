{ config
, lib
, pkgs
, ...
}:
let
  actionCmd = action: text: if action == "" then text else "<action=`${action}` button=1>${text}</action>";

  toggleAudioCmd = "${pkgs.alsa-utils}/bin/amixer set Master toggle";
  toggleMicCmd = "${pkgs.alsa-utils}/bin/amixer set Capture toggle";
  openWeatherUrlCmd = "${config.browserExec} https://www.meteo.pl/";

  statuses = pkgs.writeShellScriptBin "statuses" ''
    # right separator
    printf " "

    # playerctl status
    case $(${pkgs.playerctl}/bin/playerctl status) in
      Playing)
        printf "<fc=${config.gui.theme.base0C}>%s</fc> \\ue0b3 " "$(${pkgs.playerctl}/bin/playerctl metadata --format "{{ trunc(artist,15) }}: {{ trunc(title,40) }}")"
        ;;
      Paused)
        printf "<fc=${config.gui.theme.base04}>%s</fc> \\ue0b3 " "$(${pkgs.playerctl}/bin/playerctl metadata --format "{{ trunc(artist,15) }}: {{ trunc(title,40) }}")"
        ;;
    esac

    # dunst notifications status
    case $(${pkgs.dunst}/bin/dunstctl is-paused) in
      true )
        count=$(${pkgs.dunst}/bin/dunstctl count waiting)
        [ "$count" != "0" ] && printf "<fc=${config.gui.theme.base01}>  $count</fc> "
        ;;
      false )
        count=$(${pkgs.dunst}/bin/dunstctl count displayed)
        [ "$count" != "0" ] && printf "  $count "
        ;;
    esac

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
      Config
        { font            = "${config.gui.font.name} ${builtins.toString config.gui.font.size}"
        , bgColor         = "${config.gui.theme.base00}"
        , fgColor         = "${config.gui.theme.base0F}"
        , position        = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
        , lowerOnStart    = True
        , sepChar         = "%"
        , alignSep        = "}{"
        , template        = "%UnsafeStdinReader%}{%statuses%%mail%%multicpu%%memory%%disku%%default:Capture%%default:Master%${if config.gui.showBattery then "%battery%" else ""}%dynnetwork%${if config.gui.showWiFi then "%wlan0wi%" else ""}%EPLL%%date%"
        , commands        = [ Run NotmuchMail "mail"         [ MailItem "  " "" "tag:unread"
                                                             ] 50

                            , Run ComX "statuses"            [] " " "${statuses}/bin/statuses" 10

                            , Run MultiCpu                   [ "-t", " \xE0B3   <vbar> "
                                                             , "-L", "30", "-H", "70"
                                                             , "-l", "${config.gui.theme.base02}"
                                                             , "-n", "${config.gui.theme.base03}"
                                                             , "-h", "${config.gui.theme.base01}"
                                                             ] 10

                            , Run Memory                     [ "-t", "\xE0B3   <usedvbar> "
                                                             , "-L", "30", "-H", "70"
                                                             , "-l", "${config.gui.theme.base02}"
                                                             , "-n", "${config.gui.theme.base03}"
                                                             , "-h", "${config.gui.theme.base01}"
                                                             ] 10

                            , Run DiskU                      [ ("/", "\xE0B3   <usedvbar> ") ]
                                                             [ "-L", "30", "-H", "70"
                                                             , "-l", "${config.gui.theme.base02}"
                                                             , "-n", "${config.gui.theme.base03}"
                                                             , "-h", "${config.gui.theme.base01}"
                                                             ] 100

                            , Run Volume "default" "Capture" [ "-t", "\xE0B3 ${actionCmd toggleMicCmd "<status>"} "
                                                             , "--"
                                                             , "-C", "${config.gui.theme.base0F}"
                                                             , "-c", "${config.gui.theme.base0F}"
                                                             , "-O", "", "-o", " "
                                                             ] 10

                            , Run Volume "default" "Master"  [ "-t", "${actionCmd toggleAudioCmd "<status>"} <volumevbar> "
                                                             , "--"
                                                             , "-C", "${config.gui.theme.base0F}"
                                                             , "-c", "${config.gui.theme.base0F}"
                                                             , "-O", " ", "-o", " "
                                                             ] 10

                            , Run Battery                    [ "-t", "\xE0B3 <acstatus> "
                                                             , "--"
                                                             , "-O", "󱊥  <leftvbar>"
                                                             , "-i", "󱊦  <leftvbar>"
                                                             , "-o", "󱊢 <timeleft> <leftvbar>"
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
                                                             , ("considerable cloudiness", "overcast")
                                                             ]
                                                             [ "-t", "<fc=${config.gui.theme.base07},${config.gui.theme.base08}>\xE0B2</fc><fc=${config.gui.theme.base00},${config.gui.theme.base07}> ${actionCmd openWeatherUrlCmd "<skyConditionS> <tempC>\\x2103 <rh>% <windKnots>kn <windCardinal>"} </fc>"
                                                             ] 18000

                            , Run UnsafeStdinReader
                            ]
        }
    '';
  };
}
