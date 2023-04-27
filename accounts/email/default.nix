{ pkgs, settings, ... }:
{
  maildirBasePath = "${settings.dirs.home}/.mail";
  accounts = {
    silquenarmo = import ./silquenarmo.nix { inherit pkgs; };
    placzynski = import ./placzynski-pawel.nix { inherit pkgs; };
    binarapps = import ./p-placzynski-binarapps.nix { inherit pkgs; };
    futurelearn = import ./pawel-placzynski-futurelearn.nix { inherit pkgs; };
    byron = import ./pawel-placzynski-byron.nix { inherit pkgs; };
  };
}
