{ config, pkgs, lib, ... }:

let
  statuses = pkgs.writeShellScriptBin "eww-statuses" ''
    case $(${pkgs.playerctl}/bin/playerctl status 2>/dev/null) in
      Playing) echo "$(${pkgs.playerctl}/bin/playerctl metadata --format '{{artist}}: {{title}}' 2>/dev/null)" ;;
      Paused)  echo paused ;;
    esac

    if [ $(${pkgs.dunst}/bin/dunstctl is-paused) = "true" ]; then
      cnt=$(${pkgs.dunst}/bin/dunstctl count waiting)
      [ "$cnt" != "0" ] && echo " $cnt"
    else
      cnt=$(${pkgs.dunst}/bin/dunstctl count displayed)
      [ "$cnt" != "0" ] && echo " $cnt"
    fi
  '';
in {
  options = with lib; {
    gui.showWiFi = mkEnableOption "Show WiFi status in the bar.";
    gui.showBattery = mkEnableOption "Show battery status in the bar.";
  };

  config = {
    home.packages = [ pkgs.eww pkgs.alsa-utils pkgs.notmuch pkgs.wirelesstools statuses ];

    programs.eww.enable = true;
#     programs.eww.configDir = "${config.xdg.configHome}/eww";

    xdg.configFile."eww/eww.yuck" = {
      enable = true;
      text = ''
      (defwidget bar []
  (centerbox :orientation "h"
    (workspaces)
    (music)
    (sidestuff)))

(defwidget sidestuff []
  (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
    (metric :label "🔊"
            :value volume
            :onchange "amixer -D pulse sset Master {}%")
    (metric :label ""
            :value {EWW_RAM.used_mem_perc}
            :onchange "")
    (metric :label "💾"
            :value {round((1 - (EWW_DISK["/"].free / EWW_DISK["/"].total)) * 100, 0)}
            :onchange "")
    time))

(defwidget workspaces []
  (box :class "workspaces"
       :orientation "h"
       :space-evenly true
       :halign "start"
       :spacing 10
    (button :onclick "wmctrl -s 0" 1)
    (button :onclick "wmctrl -s 1" 2)
    (button :onclick "wmctrl -s 2" 3)
    (button :onclick "wmctrl -s 3" 4)
    (button :onclick "wmctrl -s 4" 5)
    (button :onclick "wmctrl -s 5" 6)
    (button :onclick "wmctrl -s 6" 7)
    (button :onclick "wmctrl -s 7" 8)
    (button :onclick "wmctrl -s 8" 9)))

(defwidget music []
  (box :class "music"
       :orientation "h"
       :space-evenly false
       :halign "center"
    {music != "" ? "🎵$'{music}" : ""}))


(defwidget metric [label value onchange]
  (box :orientation "h"
       :class "metric"
       :space-evenly false
    (box :class "label" label)
    (scale :min 0
           :max 101
           :active {onchange != ""}
           :value value
           :onchange onchange)))



(deflisten music :initial ""
  "playerctl --follow metadata --format '{{ artist }} - {{ title }}' || true")

(defpoll volume :interval "1s"
  "scripts/getvol")

(defpoll time :interval "10s"
  "date '+%H:%M %b %d, %Y'")

(defwindow bar
  :monitor 0
  :windowtype "dock"
  :geometry (geometry :x "0%"
                      :y "0%"
                      :width "90%"
                      :height "10px"
                      :anchor "top center")
  :reserve (struts :side "top" :distance "4%")
  (bar))
      '';
    };

    xdg.configFile."eww/eww.scss" = {
      enable = true;
      text = ''
        * {
          font-family: "${config.gui.font.name}";
          font-size: ${builtins.toString config.gui.font.size}px;
          color: ${config.gui.theme.base0F};
        }
        .bar {
          background: ${config.gui.theme.base00};
          padding: ${builtins.toString config.gui.border.size}px;
        }
      '';
    };
  };
}
