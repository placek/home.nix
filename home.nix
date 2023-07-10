{ config
, ...
}:
let
  sources = import ./home.lock.nix;
  settings = import ./settings;
  inherit (sources) pkgs;
in
{
  home.stateVersion = "23.05";
  home.username = settings.user.name;
  home.homeDirectory = settings.dirs.home;

  fonts.fontconfig.enable = true;

  nix.package = pkgs.nix;
  nix.settings.system-features = [ "big-parallel" "kvm" "benchmark" ];

  programs.home-manager.enable = true;

  xdg.enable = true;
  xdg.systemDirs.data = [ "${settings.dirs.home}/.nix-profile/share" ];

  xresources = {
    properties = with settings.colors; {
      "*foreground" = base0F;
      "*background" = base00;
      "*cursorColor" = base0F;
      "*color0" = base00;
      "*color1" = base01;
      "*color2" = base02;
      "*color3" = base03;
      "*color4" = base04;
      "*color5" = base05;
      "*color6" = base06;
      "*color7" = base07;
      "*color8" = base08;
      "*color9" = base09;
      "*color10" = base0A;
      "*color11" = base0B;
      "*color12" = base0C;
      "*color13" = base0D;
      "*color14" = base0E;
      "*color15" = base0F;

      "*termName" = "xterm-256color";

      "Xft.dpi" = 96;
      "Xft.autohint" = true;
      "Xft.lcdfilter" = "lcdfilter";
      "Xft.hintstyle" = "hintslight";
      "Xft.hinting" = true;
      "Xft.antialias" = true;
      "Xft.rgba" = "rgb";
      "xprompt.font" = settings.font.fullName;
      "xprompt.geometry" = "0x32+0+0";
    };
  };

  # modules settings
  vcs.email = settings.user.email;
  vcs.login = settings.user.name;
  vcs.signKey = settings.key.sign;

  browser.downloadsDirectory = settings.dirs.downloads;
  browser.theme = settings.colors;

  terminal.theme = settings.colors;

  ssh.authSocket = settings.key.sshAuthSocket;

  # modules
  imports = [
    # TODO ./modules/gui
    ./modules/browser
    ./modules/terminal
    ./modules/shell
    ./modules/editor
    ./modules/vcs
    ./modules/security.nix # TODO
    ./modules/ssh
    ./modules/mail
    ./modules/utils
  ];
}
