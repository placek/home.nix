{ config, pkgs, ... }:
let
  settings = import ../settings;
in
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
    enableScDaemon = true;
    defaultCacheTtl = 1800;
    defaultCacheTtlSsh = 1800;
    sshKeys = [ settings.key.ssh ];
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = settings.key.store;
    };
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        source = settings.key.pubKey;
      }
    ];
  };
}
