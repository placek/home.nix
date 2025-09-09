{ config
, lib
, pkgs
, ...
}:
{
  config = {
    home.packages = with pkgs; [ wofi-pass ];

    programs.wofi.enable = true;
    programs.wofi.settings = {
      location = "bottom-right";
      allow_markup = true;
      width = 800;
    };

    programs.wofi.style = import ./style.nix { inherit config; };
  };
}
