{ config
, lib
, pkgs
, ...
}:
let
  gpu_status = import ./gpu_status.nix { inherit pkgs; };
  player_status = import ./player_status.nix { inherit pkgs; };
  mail_status = import ./mail_status.nix { inherit pkgs; };
in
{
  config = {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 0;

          modules-left = [ "cpu" "custom/gpu" "memory" "disk" "network" "battery" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "custom/playnow" "pulseaudio" "custom/notmuch" "clock" ];

          cpu = {
            format = "   {usage}% ";
            format-alt = "   {load} ";
            tooltip = false;
            interval = 1;
          };

          "custom/gpu" = {
            exec = "${gpu_status}/bin/gpu_status";
            format = "   {text} ";
            format-alt = "   {alt} ";
            interval = 1;
            tooltip = false;
            return-type = "json";
          };

          memory = {
            format = "   {percentage}% ";
            format-alt = "   {used:0.1f}G/{total:0.1f}G ";
            tooltip = false;
            interval = 1;
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
            format-linked = " 󱘖  {ifname} (no IP) ";
            format-disconnected = "   disconnected ";
            format-alt = " 󰅧  {bandwidthUpBytes} 󰅢  {bandwidthDownBytes} ";
            interval = 1;
            tooltip = false;
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
              "spotify" = "";
              "steam" = "";
              "office" = "";
            };
            on-click = "activate";
            disable-scroll = false;
            all-outputs = false;
          };

          "custom/playnow" = {
            exec = "${player_status}/bin/player_status";
            format = " {} ";
            hide-empty-text = true;
            interval = 1;
            tooltip = false;
            return-type = "json";
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
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
              default = [ "  " "  " "  " ];
            };
            tooltip = true;
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          };

          "custom/notmuch" = {
            exec = "${mail_status}/bin/mail_status";
            interval = 60;
            hide-empty-text = true;
            format = "   {} ";
            tooltip = true;
            return-type = "json";
          };

          clock = {
            interval = 1;
            timezone = "Europe/Warsaw";
            format = " {:L%A %Y-%m-%d %H:%M} ";
            tooltip = false;
          };
        };
      };

      style = import ./style.nix { inherit config; };
    };
  };
}
