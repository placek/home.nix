{ config
, lib
, pkgs
, ...
}:
let
  gpu_status = import ./gpu_status.nix { inherit pkgs config; };
  mail_status = import ./mail_status.nix { inherit pkgs; };
  weather_status = import ./weather_status.nix { inherit pkgs config; };
  clock_status = import ./clock_status.nix { inherit pkgs config; };
  dunst_status = import ./dunst_status.nix { inherit pkgs; };
  micIcon = builtins.fromJSON ''"\uf130"'';      # nf-fa-microphone
  micMuteIcon = builtins.fromJSON ''"\uf131"'';  # nf-fa-microphone_slash
  btIcon = builtins.fromJSON ''"\udb80\udcaf"'';      # nf-md-bluetooth
  btConnIcon = builtins.fromJSON ''"\udb80\udcb1"'';  # nf-md-bluetooth_connect
  btOffIcon = builtins.fromJSON ''"\udb80\udcb2"'';   # nf-md-bluetooth_off
in
{
  config = {
    programs.waybar = {
      systemd.enable = true;
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 0;

          modules-left = [ "group/stats" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "custom/notmuch" "battery" "group/media" "group/here" "custom/dnd" ];

          "group/stats" = {
            orientation = "inherit";
            modules = [ "cpu" "custom/gpu" "memory" "disk" "network" "bluetooth" ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = true;
            };
          };

          "group/media" = {
            orientation = "inherit";
            modules = [ "pulseaudio" "pulseaudio#source" "mpris" ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = false;
            };
          };

          "group/here" = {
            orientation = "inherit";
            modules = [ "custom/clock" "custom/weather" ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = false;
            };
          };

          cpu = {
            format = " {icon} {usage}% ";
            format-alt = " {icon} {avg_frequency}/{max_frequency} GHz ({load}) ";
            tooltip = false;
            interval = 1;
            format-icons = [
              "<span color=\"${config.gui.theme.base02}\"> </span>"
              "<span color=\"${config.gui.theme.base03}\"> </span>"
              "<span color=\"${config.gui.theme.base01}\"> </span>"
            ];
          };

          "custom/gpu" = {
            exec = "${gpu_status}/bin/gpu_status";
            format = " {text} ";
            format-alt = " {alt} ";
            interval = 1;
            tooltip = false;
            return-type = "json";
          };

          memory = {
            format = " {icon} {percentage}% ";
            format-alt = " {icon} {used:0.1f}/{total:0.1f} GB ";
            tooltip = false;
            interval = 1;
            format-icons = [
              "<span color=\"${config.gui.theme.base02}\"> </span>"
              "<span color=\"${config.gui.theme.base03}\"> </span>"
              "<span color=\"${config.gui.theme.base01}\"> </span>"
            ];
          };

          disk = {
            format = "   {percentage_used}% ";
            format-alt = "   {used}/{total} ";
            path = "/";
            interval = 60;
            tooltip = false;
          };

          network = {
            format-wifi = " 󰖩  {essid} ";
            format-ethernet = " 󱘖  {ifname} ";
            format-alt = " 󱘖  {ipaddr}/{cidr} ";
            format-linked = " 󱘖  {ifname} (no IP) ";
            format-disconnected = " 󱘖  disconnected ";
            tooltip-format = " 󰅧  {bandwidthUpBytes} 󰅢  {bandwidthDownBytes} ";
            interval = 1;
          };

          bluetooth = {
            format = " ${btIcon} ";
            format-disabled = " ${btOffIcon} ";
            format-off = " ${btOffIcon} ";
            format-connected = " ${btConnIcon}  {num_connections} ";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            on-click = "blueman-manager";
          };

          battery = {
            states.warning = 30;
            states.critical = 15;
            format = " {icon}  {capacity}% ";
            format-discharging = " {icon}  {capacity}% ({time}) ";
            format-charging = " 󱐋 {capacity}% ";
            interval = 1;
            format-icons = ["" "" "" "" ""];
            tooltip = false;
          };

          "hyprland/workspaces" = {
            format = "{windows} ";
            format-window-separator = "  ";
            window-rewrite-default = "  {title}";
            window-rewrite = {
              "qutebrowser" = "  qutebrowser";
              "firefox" = "  firefox";
              "kitty" = "  {title}";
              "slack" = "  {title}";
              "inkscape" = "  {title}";
              "gimp" = "  {title}";
              "cad" = "  {title}";
              "spotify" = "  {title}";
              "steam" = "  {title}";
              "office" = "  {title}";
              "musescore" = " {title}";
            };
            on-click = "activate";
            disable-scroll = false;
            all-outputs = false;
          };

          mpris = {
            format = " <span color=\"${config.gui.theme.base03}\">{player_icon}</span> ";
            format-paused = " {status_icon} ";
            player-icons = {
              default = "▶";
              mpv = " ";
              spotify = " ";
              chromium = " ";
            };
            status-icons = {
              paused = "";
            };
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
            on-click-middle = "${pkgs.playerctl}/bin/playerctl play-pause --all-players";
            on-click-right = "${pkgs.playerctl}/bin/playerctl pause --all-players";
          };

          pulseaudio = {
            format = " {icon} {volume}% ";
            format-muted = " 󰖁  {volume}% ";
            format-icons = {
              headphone = " ";
              hands-free = " ";
              headset = " ";
              phone = " ";
              portable = " ";
              car = " ";
              default = [
                "<span color=\"${config.gui.theme.base02}\"> </span>"
                "<span color=\"${config.gui.theme.base03}\"> </span>"
                "<span color=\"${config.gui.theme.base01}\"> </span>"
              ];
            };
            tooltip = true;
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          };

          "custom/notmuch" = {
            exec = "${mail_status}/bin/mail_status";
            interval = 60;
            hide-empty-text = true;
            format = " <span color=\"${config.gui.theme.base03}\"> </span> {} ";
            tooltip = true;
            return-type = "json";
            on-click = "${pkgs.kitty}/bin/kitty -e ${pkgs.alot}/bin/alot";
          };

          "custom/weather" = {
            exec = "${weather_status}/bin/weather_status";
            interval = 3600;
            format = " {} ";
            tooltip = true;
            return-type = "json";
          };

          "custom/clock" = {
            exec = "${clock_status}/bin/clock_status";
            interval = 60;
            format = " {} ";
            tooltip = true;
            return-type = "json";
          };

          "pulseaudio#source" = {
            format = "{format_source}";
            format-source = " ${micIcon}  {volume}% ";
            format-source-muted = " ${micMuteIcon} ";
            on-click = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            tooltip = false;
          };

          "custom/dnd" = {
            exec = "${dunst_status}/bin/dunst_status";
            interval = 2;
            return-type = "json";
            format = " {} ";
            tooltip = true;
            on-click = "${pkgs.dunst}/bin/dunstctl set-paused toggle";
          };
        };
      };

      style = import ./style.nix { inherit config; };
    };
  };
}
