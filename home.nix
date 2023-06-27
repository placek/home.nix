{ config, ... }:
let
  sources = import ./home.lock.nix;
  settings = import ./settings;
  secrets = import ./secrets;
  inherit (sources) pkgs glpkgs;
in
{
  accounts = import ./accounts { inherit pkgs settings; };
  home = import ./home { inherit glpkgs pkgs settings secrets; };
  nix = import ./nix { inherit pkgs secrets; };
  programs = import ./programs { inherit pkgs settings; };
  services = import ./services { inherit config settings; };
  xdg = import ./xdg { inherit config pkgs settings; };
  xresources = import ./xresources { inherit settings; };

  fonts.fontconfig.enable = true;

  imports = [
    # ./modules/xmonad.nix
    ./modules/browser.nix
    ./modules/terminal.nix
    ./modules/shell.nix
    ./modules/editor
  ];
}
