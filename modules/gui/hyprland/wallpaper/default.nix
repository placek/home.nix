{ config
, pkgs
, ...
}:
{
  config = {
    home.file.background = {
      source = ./wallpaper.jpg;
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
