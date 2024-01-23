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
in
{
  config = {
    home.packages = [
      wine-rome-total-war
      wine-rome-barbarian-invasion
      wine-rome-alexander

      pkgs.wineWowPackages.stable
      pkgs.steam
    ];
  };
}
