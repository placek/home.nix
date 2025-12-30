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
    accounts.email.accounts = lib.mapAttrs
      (key: value: account.details pkgs.pass config.vcs.name key value.email (key == config.mail.primaryAccount))
      config.mail.accounts;
  };
}
