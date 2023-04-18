{ pkgs, ... }:
let
  settings = import ../../settings;
in
{
  maildirBasePath = "${settings.dirs.home}/.mail";
  accounts = {
    silquenarmo = import ./silquenarmo.nix { inherit pkgs; };
    placzynski-pawel = import ./placzynski-pawel.nix { inherit pkgs; };
    p-placzynski-binarapps = import ./p-placzynski-binarapps.nix { inherit pkgs; };
    # pawel-placzynski-futurelearn = import ./pawel-placzynski-futurelearn.nix { inherit pkgs; };
    # pawel-placzynski-byron = import ./pawel-placzynski-byron.nix { inherit pkgs; };
  };
}
