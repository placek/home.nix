{ config
, lib
, pkgs
, ...
}:
{
  imports = [
    ./wallpaper
    ./waybar
    ./wofi
    ./bindings.nix
    ./cursor.nix
  ];

  config = {
    home.packages = with pkgs; [
      wl-clipboard
#       udiskie
    ];

    # Start services/utilities on session start
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        general.gaps_in = 4;
        general.gaps_out = 8;
        general.border_size = 4;
        general."col.active_border" = "rgb(${lib.removePrefix "#" config.gui.theme.base0B})";
        general."col.inactive_border" = "rgb(${lib.removePrefix "#" config.gui.theme.base08})";
        general.layout = "master";
        decoration.rounding = 4;
        decoration.active_opacity = 1.0;
        decoration.inactive_opacity = 0.9;
        animations.enabled = true;
        input.follow_mouse = 1;
        input.kb_layout = "pl,us";
        master.new_status = "master";
        master.new_on_top = true;
        master.orientation = "left";
        master.mfact = 0.66;

        windowrulev2 = [
          "tile, class:^(kitty)$"
  #         "float,xwayland:0,$type=dialog"
  #         "center, title:.*,xwayland:0,$type=dialog"
  #         "fullscreen,title:.*,floating:0,$type=fullscreen"
        ];

        exec-once = [
          "${pkgs.swaynotificationcenter}/bin/swaync &"
#           "${pkgs.cliphist}/bin/cliphist store &"
          "${config.programs.waybar.package}/bin/waybar &"
        ];
      };
    };

    # Hyprlock minimal theme with your colors (optional)
    xdg.configFile."hypr/hyprlock.conf".text = ''
      general {
        no_fade_in = true
      }
      background {
        color = ${config.gui.theme.base00}
      }
      input-field {
        roundings = 6
        font_color  = ${config.gui.theme.base0F}
        inner_color = ${config.gui.theme.base00}
        outer_color = ${config.gui.theme.base03}
        fail_color  = ${config.gui.theme.base08}
      }
    '';
  };
}

