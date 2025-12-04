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
    prefix = "rome-total-war";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-ALX.exe";
  };

  wine-rome-total-war-enhancement = import ./run_in_wine.nix {
    inherit pkgs config;
    name = "rome-total-war-enhancement";
    path = "Program Files (x86)/The Creative Assembly/Rome - Total War";
    exe  = "RomeTW-ALX.exe -show_err -mod:HRTW -noalexander";
  };
in
{
#   imports = [ ./dwarves ];

  config = {
    home.packages = [
      wine-rome-total-war
      wine-rome-total-war-alexander
      wine-rome-total-war-barbarian-invasion
      wine-rome-total-war-enhancement

      (pkgs.prismlauncher.override { jdks = [ pkgs.temurin-bin ]; })

      pkgs.wineWowPackages.stable
      pkgs.steam
    ];
  };
}
