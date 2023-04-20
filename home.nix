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

  xdg.enable = true;
  xdg.configFile."mbsync/preExec" = {
    text = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.libnotify}/bin/notify-send "Mail" "Syncing…"
    '';
    executable = true;
  };
  xdg.configFile."mbsync/postExec" = {
    text = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.notmuch}/bin/notmuch new
      ${pkgs.libnotify}/bin/notify-send "Mail" "Synced!"
    '';
    executable = true;
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

  systemd.user.services = {
    ydotoold = {
      Unit = {
        Description = "ydotool daemon with keyboard only";
        Documentation = [ "man:ydotoold(1)" ];
      };
      Service = {
        ExecStart = "${pkgs.ydotool}/bin/ydotoold --mouse-off --touch-off";
      };
      Install = {
        WantedBy = [ "gnome-session.target" ];
      };
    };
  };
}
