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

  wine-rome-total-war-barbarian-invasion = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-total-war-barbarian-invasion";
    prefix = "rome-total-war";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-BI.exe";
  };

  wine-rome-total-war-alexander = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-total-war-alexander";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-ALX.exe";
  };

  dwarf-fortress = (import (builtins.fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/3f888f673360440b6b7e6994a1e6d092d7588e84.tar.gz"; }) {}).pkgs.dwarf-fortress.override {
    enableIntro = false;
    enableFPS = true;
  };
in
{
  config = {
    home.packages = [
      wine-rome-total-war
      wine-rome-total-war-alexander
      wine-rome-total-war-barbarian-invasion
      dwarf-fortress

      pkgs.wineWowPackages.stable
      pkgs.steam
    ];
  };
}
