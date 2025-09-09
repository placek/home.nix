{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.wofi.enable = true;
    programs.wofi.settings = {
      location = "bottom-right";
      allow_markup = true;
      width = 800;
    };

    xdg.configFile."clipcat/clipcat-menu.toml".text = ''
      finder = "custom"

      [custom_finder]
      program = "${config.programs.wofi.package}/bin/wofi"
      args = ["--dmenu", "--prompt", "clipboard"]
    '';

    programs.wofi.style = import ./style.nix { inherit config; };
  };
}
