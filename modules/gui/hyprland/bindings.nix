{ pkgs
, config
, ...
}:
let
  clipboard_menu = pkgs.writeShellScriptBin "clipboard_menu" ''
    exec ${config.services.clipcat.package}/bin/clipcat-menu --finder=custom insert "$@"
  '';
  udisksMenu = ''
    ${pkgs.udiskie}/bin/udiskie-umount -a; ${pkgs.udiskie}/bin/udiskie-mount -a
  '';
in
{
  config = {
    home.packages = [ clipboard_menu ];
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
        "$mod, b,      exec, ${pkgs.wofi-pass}/bin/wofi-pass"
        "$mod, n,      exec, ${clipboard_menu}/bin/clipboard_menu"
#         "$mod, m,      exec, sh -c '${udisksMenu}'"

        # Notifications: history “pop” (panel) / toggle DND
        "$mod, Escape, exec, ${pkgs.dunst}/bin/dunstctl history-pop"
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
      ];
    };
  };
}
