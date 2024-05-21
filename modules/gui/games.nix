{ config
, lib
, pkgs
, ...
}:
let
  wine-rome-total-war = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-total-war";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW.exe";
  };

  wine-rome-barbarian-invasion = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-barbarian-invasion";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-BI.exe";
  };

  wine-rome-alexander = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-alexander";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-ALX.exe";
  };
  df = (import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/3f888f673360440b6b7e6994a1e6d092d7588e84.tar.gz"; }) {}).pkgs.dwarf-fortress.override {
    theme = "spacefox";
    enableIntro = false;
    enableFPS = true;
  };
in
{
  config = {
    home.packages = [
      wine-rome-total-war
      wine-rome-barbarian-invasion
      wine-rome-alexander
      df

      pkgs.wineWowPackages.stable
      pkgs.steam
    ];
  };
}
