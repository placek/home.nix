{ config
, lib
, pkgs
, ...
}:
{
  config = {
    home.stateVersion = "25.05";
    home.username = "placek";
    home.homeDirectory = "/home/placek";
    home.packages = [ pkgs.gnumake ];

    nix.package = pkgs.nix;
    nix.settings.system-features = [ "big-parallel" "kvm" "benchmark" ];
    nixpkgs.config.allowUnfree = true;

    programs.home-manager.enable = true;

    xdg.enable = true;
    xdg.systemDirs.data = [ "${config.home.profileDirectory}/share" ];

    # modules settings
    gui.theme = import ./theme.nix;
    gui.font.name = "Iosevka Nerd Font";
    gui.font.size = 12;

    vcs.name = "Paweł Placzyński";
    vcs.email = "placzynski.pawel@gmail.com";
    vcs.login = "placek";
    vcs.signKey = "28D17527E92093C9";

    ssh.authSocket = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
    ssh.secretKeyID = "C9ADBD2287A0D484"; # TODO
    ssh.publicKey = ./placek.asc;

    security.gpgKeyID = "84958051223BF9D6";
    security.gpgKeyFP = "EC134A7FE2EACDA6D82A1FA084958051223BF9D6";
    security.passwordStore = "${config.home.homeDirectory}/.password-store";

    mail.accounts = {
      placzynski.email = "placzynski.pawel@gmail.com";
      placzynski.key = "a";
      silquenarmo.email = "silquenarmo@gmail.com";
      silquenarmo.key = "s";
      binarapps.email = "p.placzynski@binarapps.com";
      binarapps.key = "d";
    };
  };
}
