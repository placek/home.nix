{ config
, pkgs
, lib
, ...
}:
{
  options = with lib; {
    ssh.authSocket = mkOption {
      type = types.str;
      example = "$HOME/.ssh/socket";
      description = "Path to SSH authentication socket.";
    };
  };

  config = {
    home.sessionVariables.SSH_AUTH_SOCK = config.ssh.authSocket;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          ControlMaster = "auto";
          ControlPersist = "10m";
        };
        dev = {
          User = "byron";
          HostName = "185.48.176.109";
        };
      };
    };
  };
}
