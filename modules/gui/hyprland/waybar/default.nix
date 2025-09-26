{ config
, lib
, pkgs
, ...
}:
let
  gpu_status = import ./gpu_status.nix { inherit pkgs config; };
  mail_status = import ./mail_status.nix { inherit pkgs; };
  weather_status = import ./weather_status.nix { inherit pkgs config; };
in
{
  config = {
    home.packages = with pkgs; [ weather_status ];
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
          modules-right = [ "custom/notmuch" "battery" "group/media" "group/here" ];

          "group/stats" = {
            orientation = "inherit";
            modules = [ "cpu" "custom/gpu" "memory" "disk" "network" ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = true;
            };
          };

          "group/media" = {
            orientation = "inherit";
            modules = [ "pulseaudio" "mpris" ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = false;
            };
          };

          "group/here" = {
            orientation = "inherit";
            modules = [ "clock" "custom/weather" ];
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
            window-rewrite-default = "";
            window-rewrite = {
              "qutebrowser" = "";
              "kitty" = "";
              "slack" = "";
              "inkscape" = "";
              "gimp" = "";
              "cad" = "";
              "spotify" = "";
              "steam" = "";
              "office" = "";
              "musescore" = "";
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
            format = "{icon} {volume}% ";
            format-muted = " 󰖁  {volume}% ";
            format-icons = {
              headphone = "  ";
              hands-free = "  ";
              headset = "  ";
              phone = "  ";
              portable = "  ";
              car = "  ";
              default = [
                " <span color=\"${config.gui.theme.base02}\"> </span>"
                " <span color=\"${config.gui.theme.base03}\"> </span>"
                " <span color=\"${config.gui.theme.base01}\"> </span>"
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

          clock = {
            interval = 1;
            timezone = "Europe/Warsaw";
            format = " {:L%F %R} ";
            format-alt = " {:L%A (%W) %d %B %Y, %H:%M %z (%Z)} ";
            tooltip-format = "{calendar}";
            actions.on-scroll-up = "shift_up";
            actions.on-scroll-down = "shift_down";
            calendar = {
              mode = "month";
              on-scroll = 1;
              weeks-pos = "right";
              format.today = "<span color=\"${config.gui.theme.base0F}\">{}</span>";
            };
          };
        };
      };

      style = import ./style.nix { inherit config; };
    };
  };
}
