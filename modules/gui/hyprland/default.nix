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

  options = with lib; {
    gui.border.size = mkOption {
      type = types.int;
      default = 4;
      description = "A border size.";
    };

    gui.border.radius = mkOption {
      type = types.int;
      default = 6;
      description = "A border radius size.";
    };
  };

  config = {
    home.packages = with pkgs; [ wl-clipboard ];

    # Start services/utilities on session start
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      settings = {
        general.gaps_in = config.gui.border.size;
        general.gaps_out = config.gui.border.size * 2;
        general.border_size = config.gui.border.size;
        general."col.active_border" = "rgb(${lib.removePrefix "#" config.gui.theme.base0B})";
        general."col.inactive_border" = "rgb(${lib.removePrefix "#" config.gui.theme.base08})";
        general.layout = "master";
        decoration.rounding = config.gui.border.radius;
        decoration.active_opacity = 1.0;
        decoration.inactive_opacity = 0.9;
        animations.enabled = true;
        input.follow_mouse = 1;
        input.kb_layout = "pl,us";
        master.new_status = "master";
        master.new_on_top = true;
        master.orientation = "left";
        master.mfact = 0.66;
        monitor = [
          "DP-5,1920x1080@60,0x0,1"
          "DP-4,1920x1080@60,1920x0,1"
        ];
        workspace = [
          "1, monitor:DP-5"
          "2, monitor:DP-5"
          "3, monitor:DP-5"
        ];

        windowrulev2 = [ "tile, class:^(kitty)$" ];
      };
    };
  };
}
