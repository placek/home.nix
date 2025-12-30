{ config
, lib
, pkgs
, ...
}:
let
  account = import ./account.nix;
in
{
  options = with lib; {
    mail.accounts = mkOption {
      type = types.attrs;
      description = "Email account configurations.";
      default = {};
    };

    mail.primaryAccount = mkOption {
      type = types.str;
      description = "Primary email account key.";
      default = "placzynski";
    };
  };

  imports = [
    ./alot.nix
    ./mbsync.nix
    ./notmuch.nix
  ];

  config = {
    programs.msmtp.enable = true;

    accounts.email.maildirBasePath = "${config.home.homeDirectory}/.mail";
    accounts.email.accounts = lib.mapAttrs (key: value: account.details {
      isPrimary = key == config.mail.primaryAccount;
      pass = pkgs.pass;
      name = config.vcs.name;
      identity = key;
      email = value.email;
    }) config.mail.accounts;
  };
}
