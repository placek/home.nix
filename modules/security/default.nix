{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    ssh.secretKeyID = mkOption {
      type = types.str;
      description = "A secret SSH key ID.";
    };

    ssh.publicKey = mkOption {
      type = types.path;
      description = "A public SSH key.";
    };

    security.passwordStore = mkOption {
      type = types.str;
      description = "A public SSH key.";
    };

    security.gpgKeyID = mkOption {
      type = types.str;
      description = "A public GPG key ID.";
    };
  };

  config = {
    home.sessionVariables.KEYID = config.security.gpgKeyID;

    home.packages = with pkgs; [
      pinentry-gtk2
      qtpass
      (pkgs.writeShellScriptBin "bavpn" "sudo openvpn ${./binarapps-office.ovpn}")
    ];

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gtk2;
      enableSshSupport = true;
      enableScDaemon = true;
      defaultCacheTtl = 1800;
      defaultCacheTtlSsh = 1800;
      sshKeys = [ config.ssh.secretKeyID ];
    };

    programs.password-store = {
      enable = true;
      package = lib.hiPrio (pkgs.pass.withExtensions (exts: [ exts.pass-otp ]));
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
