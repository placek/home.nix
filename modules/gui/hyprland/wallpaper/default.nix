{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    gui.wallpaper = mkOption {
      type = types.path;
      default = ./wallpaper.jpg;
      description = "A wallpaper.";
      readOnly = true;
    };
  };

  config = {
    home.file.background = {
      source = config.gui.wallpaper;
      target = ".wallpaper.jpg";
    };

    services.hyprpaper.enable = true;
    services.hyprpaper.settings = {
      ipc = "on";
      splash = false;
      preload = [ "~/.wallpaper.jpg" ];
      wallpaper = [ ",~/.wallpaper.jpg" ];
    };
  };
}
