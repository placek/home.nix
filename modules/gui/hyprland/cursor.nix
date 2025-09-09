{ pkgs
, config
, ...
}:
{
  config = {
    home.packages = [ pkgs.capitaine-cursors ];
    home.pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    wayland.windowManager.hyprland.settings.env = [
      "XCURSOR_THEME,capitaine-cursors"
      "XCURSOR_SIZE,24"
    ];
  };
}
