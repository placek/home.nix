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
      matchBlocks = {
        dev = {
          user = "byron";
          hostname = "185.48.176.109";
        };
      };
    };
  };
}
