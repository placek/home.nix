{ config
, lib
, pkgs
, ...
}: 
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

          modules-left = [ "cpu" "custom/gpu" "memory" "disk" "network" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "custom/playnow" "pulseaudio" "battery" "clock" ];

          "hyprland/workspaces" = {
            format = "{icon} {windows}";
            format-window-separator = " ";
            window-rewrite-default = "";
            window-rewrite = {
              "qutebrowser" = "";
              "kitty" = "";
              "slack" = "";
              "inkscape" = "";
              "gimp" = "";
              "cad" = "";
              "spotify" = "";
            };
            on-click = "activate";
            disable-scroll = false;
            all-outputs = false;
          };

          "custom/gpu" = {
            exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo '0'";
            format = " 󰍛  {}% ";
            interval = 1;
            tooltip = false;
          };

          "custom/playnow" = {
            exec = "${pkgs.playerctl}/bin/playerctl status >/dev/null 2>&1 && ${pkgs.playerctl}/bin/playerctl metadata --format '{{ artist }} - {{ title }}' || echo '-'";
            format = " 󰎆  {} ";
            interval = 5;
            tooltip = false;
          };

          disk = {
            format = "   {used}/{total} ";
            path = "/";
            interval = 60;
            tooltip = false;
          };

          network = {
            format-wifi = " 󰖩  {essid} ";
            format-ethernet = "   Wired ";
            format-linked = " 󱘖  {ifname} (No IP) ";
            format-disconnected = "   Disconnected ";
            format-alt = " 󰅧  {bandwidthUpBytes} 󰅢  {bandwidthDownBytes} ";
            interval = 1;
            tooltip = false;
          };

          battery = {
            states.warning = 30;
            states.critical = 15;
            format = " {icon}  {capacity}% ";
            format-charging = " 󱐋 {capacity}% ";
            interval = 1;
            format-icons = ["" "" "" "" ""];
            tooltip = false;
          };

          pulseaudio = {
            format = "{icon} {volume}% ";
            format-muted = " 󰖁  0% ";
            format-icons = {
              headphone = "  ";
              hands-free = "  ";
              headset = "  ";
              phone = "  ";
              portable = "  ";
              car = "  ";
              default = [ "  " "  " "  " ];
            };
            tooltip = false;
          };

          memory = {
            format = "   {used:0.1f}G/{total:0.1f}G ";
            tooltip = false;
            interval = 1;
          };

          cpu = {
            format = "   {usage}% ";
            tooltip = false;
            interval = 1;
          };

          clock = {
            interval = 1;
            timezone = "Europe/Warsaw";
            format = " {:L%A %Y-%m-%d %H:%M} ";
            tooltip = false;
          };
        };
      };

      style = ''
        * {
          font-family: "Iosevka Nerd Font", "Font Awesome 6 Free", "Font Awesome 6 Free Solid";
          font-weight: bold;
          font-size: 14px;
          color: ${config.gui.theme.base07};
        }

        window#waybar {
          background: rgba(0, 0, 0, 0.0);
          border: none;
        }

        #clock,
        #memory,
        #network,
        #disk,
        #pulseaudio,
        #battery,
        #backlight,
        #memory,
        #custom-playnow,
        #custom-gpu,
        #cpu {
          background-color: ${config.gui.theme.base00};
          padding: 4px 6px;
          margin-top: 0px;
          margin-left: 6px;
          margin-right: 6px;
          border-width: 0px;
          border-radius: 0px 0px 10px 10px;
        }

        #network:hover,
        #disk:hover,
        #battery:hover,
        #pulseaudio:hover,
        #custom-temperature:hover,
        #memory:hover,
        #cpu:hover,
        #custom-playnow:hover,
        #custom-gpu:hover,
        #clock:hover {
          background-color: ${config.gui.theme.base08};
        }

        button {
          background-color: ${config.gui.theme.base00};
          padding: 6px 12px;
          margin-top: 0px;
          margin-left: 6px;
          margin-right: 6px;
          border-width: 0px;
          border-radius: 10px;
        }

        button:hover {
          background-color: ${config.gui.theme.base08};
        }

        button:active {
          color: ${config.gui.theme.base03};
        }
      '';
    };
  };
}
