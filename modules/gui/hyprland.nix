{ config
, lib
, pkgs
, ...
}:

let
  # Wayland-native replacements / helpers
  passmenu = "${pkgs.wofi-pass}/bin/wofi-pass";          # pass prompt replacement
  cliphistMenu = ''
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  udisksMenu = ''
    ${pkgs.udiskie}/bin/udiskie-umount -a; ${pkgs.udiskie}/bin/udiskie-mount -a
  '';
  # Notifications: swaync (has history & DND like dunst)
  swayncctl = "${pkgs.swaynotificationcenter}/bin/swaync-client";

  # Colors from your scheme
  fontName   = "${config.gui.font.name}";
  fontSize   = builtins.toString config.gui.font.size;

  # Show last notification (approximate “history-pop”): open notification center
  notifHistoryPop = "${swayncctl} -t";  # toggle panel (closest UX to popping last)
in
{
  imports = [
    ./wallpaper.nix
    ./waybar.nix
    ./wofi.nix
  ];

  config = {
    home.packages = with pkgs; [
      wofi-pass cliphist wl-clipboard
      swaynotificationcenter   # swaync + swaync-client
      udiskie
      waybar
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
          "${pkgs.cliphist}/bin/cliphist store &"
          "${pkgs.waybar}/bin/waybar &"
        ];

        "$mod" = "SUPER";

        binds.pass_mouse_when_bound = false;
        binds.drag_threshold = 10;

        bindm = [
          # Move/Resize floating windows with mouse + SUPER
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        bind = [
          # FOCUS
          # Windows
          "$mod, j, cyclenext"
          "$mod, k, cyclenext, prev"
          # Workspaces
          "$mod CTRL, j, workspace, r+1"
          "$mod CTRL, k, workspace, r-1"
          # Monitors
          "$mod SHIFT, j, focusmonitor, +1"
          "$mod SHIFT, k, focusmonitor, -2"

          # MOVE
          # Reorder windows
          "$mod, h, swapnext"
          "$mod, l, swapnext, prev"
          # Between workspaces
          "$mod CTRL, h, movetoworkspace, r-1"
          "$mod CTRL, l, movetoworkspace, r+1"
          # Between monitors
          "$mod SHIFT, h, movewindow, mon:-1"
          "$mod SHIFT, l, movewindow, mon:+1"

          # Toggle floating
          "$mod, mouse:274, togglefloating"

          # Shrink/Expand master area (Ctrl+j/k)
          "$mod CTRL SHIFT, h, layoutmsg, mfact -0.02"
          "$mod CTRL SHIFT, l, layoutmsg, mfact +0.02"
          "$mod, mouse_down, layoutmsg, mfact -0.02"
          "$mod, mouse_up,   layoutmsg, mfact +0.02"

          # Close / Quit (q / Shift+q)
          "$mod, q, killactive"
          "$mod SHIFT, q, exec, hyprctl dispatch exit"

          # Spawn terminal / launcher / pass / clipboard / udisks
          "$mod, Return, exec, ${config.terminalExec}"
          "$mod, space,  exec, ${pkgs.wofi}/bin/wofi --show drun"
          "$mod, b,      exec, ${passmenu}"
#           "$mod, n,      exec, ${cliphistMenu}"
  #         "$mod, m,      exec, sh -c '${udisksMenu}'"

          # Notifications: history “pop” (panel) / toggle DND
#           "$mod, Escape, exec, ${notifHistoryPop}"
#           "$mod CTRL, Escape, exec, ${swayncctl} --toggle-dnd"

          # Multimedia
          ", Print, exec, ${pkgs.hyprshot}/bin/hyprshot -m region -o ${config.downloadsDirectory} -f 'screenshot_%Y-%m-%d_%H-%M-%S.png' -c"
          # Player
          ", XF86AudioPrev,  exec, ${pkgs.playerctl}/bin/playerctl previous"
          ", XF86AudioPlay,  exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioNext,  exec, ${pkgs.playerctl}/bin/playerctl next"
          # Volume via PipeWire
          ", XF86AudioMute,         exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioLowerVolume,  exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume,  exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"
          # Sleep/PowerOff keys → lock (like slock)
          ", XF86Sleep,    exec, ${pkgs.hyprlock}/bin/hyprlock"
          ", XF86PowerOff, exec, ${pkgs.hyprlock}/bin/hyprlock"

          # TODO
          # Next layout (BackSpace)
          "$mod SHIFT, BackSpace, layoutmsg, cyclenext"
        ];
      };
    };

    # swaync theming to your palette
#     xdg.configFile."swaync/style.css".text = ''
#       * { font-family: "${fontName}", "Nerd Font"; font-size: ${fontSize}px; }
#       .notification-row { background: ${c.base00}; color: ${c.base0F}; border: 1px solid ${c.base03}; border-radius: 6px; }
#       .control-center { background: ${c.base00}; color: ${c.base0F}; }
#       .close-button, .action-button { background: ${c.base0B}; color: ${c.base00}; }
#       .dnd-indicator { color: ${c.base08}; }
#     '';
#     xdg.configFile."swaync/config.json".text = builtins.toJSON {
#       "$schema" = "https://raw.githubusercontent.com/ErikReider/SwayNotificationCenter/master/resources/schemas/config.schema.json";
#       positionX = "right";
#       positionY = "top";
#       control-center-on-notif = false;
#       widgets = [ "inhibitors" "dnd" "notifications" ];
#     };

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

