{ config, lib, pkgs, ... }:
let
  sshot = import ./xmonad/sshot.nix { inherit config pkgs; };
  runPrompt = "${pkgs.writeShellScriptBin "run-prompt" "${config.gui.menuExec}"}";
  clipboardPrompt = "${pkgs.writeShellScriptBin "clipboard-prompt" "${config.home.homeDirectory}/.local/bin/clipboard-prompt"}";
  passPrompt = "${pkgs.writeShellScriptBin "pass-prompt" "${config.home.homeDirectory}/.local/bin/pass-prompt"}";
  udisksPrompt = "${pkgs.writeShellScriptBin "udisks-prompt" "${config.home.homeDirectory}/.local/bin/udisks-prompt"}";
  terminal = config.terminalExec;
  hyprlandCmd = "${pkgs.hyprland}/bin/Hyprland";
  startEww = "${pkgs.eww}/bin/eww daemon --config ${config.xdg.configHome}/eww & ${pkgs.eww}/bin/eww open bar";
  prompt = "${config.gui.menuExec}";
  clipboard = "clipboard-prompt";
  pass = "pass-prompt";
  udisks = "udisks-prompt";
  screenshotSelection = "${sshot}/bin/sshot selection";
  screenshotWindow = "${sshot}/bin/sshot window";
in
{
  config = {
    home.packages = [ pkgs.hyprland pkgs.eww sshot ];
    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.extraConfig = ''
      $mod = SUPER
      exec-once = wallpaper & ${startEww}

      bind = $mod, RETURN, exec, ${terminal}
      bind = $mod, BACKSPACE, exec, ${prompt}
      bind = $mod, C, exec, ${clipboard}
      bind = $mod, P, exec, ${pass}
      bind = $mod, M, exec, ${udisks}

      bind = $mod, H, workspace, -1
      bind = $mod, L, workspace, +1
      bind = $mod SHIFT, H, movetoworkspace, -1
      bind = $mod SHIFT, L, movetoworkspace, +1
      bind = $mod CTRL, H, focusmonitor, l
      bind = $mod CTRL, L, focusmonitor, r
      bind = $mod, K, movefocus, u
      bind = $mod, J, movefocus, d
      bind = $mod SHIFT, K, movewindow, u
      bind = $mod SHIFT, J, movewindow, d
      bind = $mod CTRL, K, resizeactive, 0 -20
      bind = $mod CTRL, J, resizeactive, 0 20
      bind = $mod, SPACE, layoutmsg, cyclenext
      bind = $mod CTRL, SPACE, togglefloating
      bind = $mod SHIFT, SPACE, centerwindow
      bind = $mod, Q, killactive
      bind = $mod SHIFT, Q, exit

      bind = , XF86AudioPrev, exec, playerctl previous
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioMute, exec, amixer set Master toggle
      bind = , XF86Calculator, exec, amixer set Capture toggle
      bind = , XF86AudioLowerVolume, exec, amixer set Master 5%- unmute
      bind = , XF86AudioRaiseVolume, exec, amixer set Master 5%+ unmute
      bind = , XF86MonBrightnessUp, exec, light -A 5
      bind = , XF86MonBrightnessDown, exec, light -U 5
      bind = , XF86Sleep, exec, slock
      bind = , XF86PowerOff, exec, slock
      bind = SHIFT, Print, exec, ${screenshotWindow}
      bind = , Print, exec, ${screenshotSelection}
    '';
  };
}
