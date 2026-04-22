{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    gui.wallpaper = mkOption {
      type = types.path;
      default = ./wallpaper.png;
      description = "A wallpaper.";
      readOnly = true;
    };
  };

  config = {
    home.file.background = {
      source = config.gui.wallpaper;
      target = ".wallpaper.png";
    };

    services.hyprpaper.enable = true;
    services.hyprpaper.settings = {
      ipc = "on";
      splash = false;
      preload = [ "~/.wallpaper.png" ];
      wallpaper = [ ",~/.wallpaper.png" ];
    };
  };
}
