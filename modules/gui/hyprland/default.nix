{ config
, pkgs
, lib
, ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "env" = [ "XCURSOR_THEME=Adwaita" "XCURSOR_SIZE=24" ];
      "$mod" = "SUPER";
      # Keep some of the keymaps from xmonad
      "bind" = [
        "$mod,H,workspace,-1"
        "$mod,L,workspace,+1"
        "$mod SHIFT,H,movetoworkspace,-1"
        "$mod SHIFT,L,movetoworkspace,+1"
        "$mod,J,movefocus,d"
        "$mod,K,movefocus,u"
        "$mod CTRL,J,resizeactive,-20 0"
        "$mod CTRL,K,resizeactive,20 0"
        "$mod,SPACE,togglefloating"
        "$mod,RETURN,exec,${config.terminalExec}"
        "$mod,BACKSPACE,exec,${config.menuExec}"
      ];
    };
    extraConfig = ''
      general {
        border_size = ${builtins.toString config.gui.border.size}
        col.active_border = rgba(${lib.removePrefix "#" config.gui.theme.base0B}ff)
        col.inactive_border = rgba(${lib.removePrefix "#" config.gui.theme.base08}ff)
      }
    '';
  };
}
