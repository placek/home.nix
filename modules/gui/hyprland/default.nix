{ config, lib, pkgs, ... }:
let
  sshot = import ./sshot.nix { inherit config pkgs; };
  wallpaperScript = "wallpaper"; # script from gui/default.nix
in {
  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        $mod = SUPER

        exec-once = ${wallpaperScript} &

        bind = $mod, RETURN, exec, ${config.terminalExec}
        bind = $mod, SPACE, exec, ${config.menuExec}
        bind = $mod SHIFT, Q, exit
        bind = $mod, Q, killactive
        bind = , Print, exec, ${sshot}/bin/sshot selection
        bind = SHIFT, Print, exec, ${sshot}/bin/sshot window
        bind = $mod, ESCAPE, exec, ${pkgs.mako}/bin/makoctl dismiss
      '';
    };

    programs.waybar.enable = true;
  };
}
