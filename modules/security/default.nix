{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  inherit (sources) pkgs;
in
{
  options = with lib; {
    ssh.secretKeyID = mkOption {
      type = types.str;
      description = mdDoc "A secret SSH key ID.";
    };

    ssh.publicKey = mkOption {
      type = types.path;
      description = mdDoc "A public SSH key.";
    };

    security.passwordStore = mkOption {
      type = types.str;
      description = mdDoc "A public SSH key.";
    };
  };

  config = {
    xdg.desktopEntries.qtpass = {
      name = "QtPass";
      genericName = "QtPass";
      type = "Application";
      exec = "qtpass";
      terminal = false;
      icon = "qtpass-icon";
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
      enableScDaemon = true;
      defaultCacheTtl = 1800;
      defaultCacheTtlSsh = 1800;
      sshKeys = [ config.ssh.secretKeyID ];
    };

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = config.security.passwordStore;
      };
    };

    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          trust = 5;
          source = config.ssh.publicKey;
        }
      ];
    };
  };
}
