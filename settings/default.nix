{ config
, lib
, pkgs
, ...
}:
let
  sources = import ../home.lock.nix;
  theme = import ./theme.nix;
in
{
  config = {
    home.stateVersion = "23.05";
    home.username = "placek";
    home.homeDirectory = "/home/placek";

    fonts.fontconfig.enable = true;

    nix.package = pkgs.nix;
    nix.settings.system-features = [ "big-parallel" "kvm" "benchmark" ];

    programs.home-manager.enable = true;

    xdg.enable = true;
    xdg.systemDirs.data = [ "/home/placek/.nix-profile/share" ];

    # modules settings
    gui.theme = theme;
    gui.font.name = "Iosevka Nerd Font";
    gui.font.size = 12;
    gui.showBattery = true;
    gui.showWiFi = true;

    vcs.name = "Paweł Placzyński";
    vcs.email = "placzynski.pawel@gmail.com";
    vcs.login = "placek";
    vcs.signKey = "1D95E554315BC053";

    ssh.authSocket = "/run/user/1000/gnupg/S.gpg-agent.ssh"; # FIXME: the SSH_AUTH_SOCK should point to pinned data
    ssh.secretKeyID = "D75BFE7D95CB0CB4B3FE0B64E624230BAE5B5299";
    ssh.publicKey = ./placek.asc;

    security.passwordStore = "/home/placek/.password-store";
  };
}
