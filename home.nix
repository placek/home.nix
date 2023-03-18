{ config, ... }:
let
  sources = import ./home.lock.nix;
  settings = import ./settings;
  inherit (sources) pkgs glpkgs;
in
{
  home.stateVersion = "22.11";
  home.username = settings.user.name;
  home.homeDirectory = settings.dirs.home;
  home.sessionVariables = {
    EDITOR = "vim";
    SHELL = "fish";
    SSH_AUTH_SOCK = settings.key.sshAuthSocket;
  };

  fonts.fontconfig.enable = true;

  home.packages = import ./packages { inherit pkgs glpkgs; };
  home.file = import ./files;
  programs = import ./programs { inherit pkgs; };
  services = import ./services { inherit pkgs; };
}
