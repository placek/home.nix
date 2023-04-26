{ config, ... }:
let
  sources = import ./home.lock.nix;
  settings = import ./settings;
  secrets = import ./secrets;
  inherit (sources) pkgs glpkgs;
in
{
  home.stateVersion = "23.05";
  home.username = settings.user.name;
  home.homeDirectory = settings.dirs.home;
  home.sessionVariables = {
    EDITOR = "vim";
    SHELL = "fish";
    SSH_AUTH_SOCK = settings.key.sshAuthSocket;
    OPENAI_API_KEY = secrets.chatGPT;
  };

  nix = {
    package = pkgs.nix;
    settings = {
      system-features = [ "big-parallel" "kvm" "benchmark" ];
      access-tokens = secrets.accessTokens;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = import ./packages { inherit pkgs glpkgs; };
  home.file = import ./files { inherit pkgs; };
  programs = import ./programs { inherit pkgs; };
  services = import ./services { inherit config pkgs; };
  accounts.email = import ./accounts/email { inherit pkgs; };
  xdg = import ./xdg { inherit config pkgs; };
}
