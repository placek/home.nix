{ pkgs
, config
, ...
}:
{
  config = {
    wayland.windowManager.hyprland.settings = {
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
        "$mod, h, cyclenext"
        "$mod, l, cyclenext, prev"
        # Workspaces
        "$mod CTRL, h, workspace, r-1"
        "$mod CTRL, l, workspace, r+1"
        # Monitors
        "$mod SHIFT, h, focusmonitor, -1"
        "$mod SHIFT, l, focusmonitor, +1"

        # MOVE
        # Reorder windows
        "$mod, y, swapnext"
        "$mod, o, swapnext, prev"
        # Between workspaces
        "$mod CTRL, y, movetoworkspace, r-1"
        "$mod CTRL, o, movetoworkspace, r+1"
        # Between monitors
        "$mod SHIFT, y, movewindow, mon:-1"
        "$mod SHIFT, o, movewindow, mon:+1"

        # Toggle floating
        "$mod, mouse:274, togglefloating"

        # Shrink/Expand master area
        "$mod, j, layoutmsg, mfact -0.02"
        "$mod, k, layoutmsg, mfact +0.02"
        "$mod, mouse_down, layoutmsg, mfact -0.02"
        "$mod, mouse_up,   layoutmsg, mfact +0.02"

        # Close / Quit
        "$mod, q, killactive"
        "$mod SHIFT, q, exec, hyprctl dispatch exit"

        # Spawn terminal / launcher / pass / clipboard / udisks
        "$mod, Return, exec, ${config.terminalExec}"
        "$mod, space,  exec, ${pkgs.wofi}/bin/wofi --show drun"
        "$mod, b,      exec, ${pkgs.wofi-pass}/bin/wofi-pass"
        "$mod, n,      exec, ${config.services.clipcat.package}/bin/clipcat-menu --finder=custom insert"
        "$mod, m,      exec, ${pkgs.udiskie}/bin/udiskie-mount -a"
        "$mod, M,      exec, ${pkgs.udiskie}/bin/udiskie-umount -a"

        # Notifications: history “pop” (panel) / toggle DND
        "$mod, Escape, exec, ${pkgs.dunst}/bin/dunstctl history-pop"

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
      ];
    };
  };
}
