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
        utils-mainnet = {
          user = "admin";
          hostname = "65.108.64.117";
          localForwards = [
            {
              bind.port = 31880;
              host.address = "127.0.0.1";
              host.port = 1880;
            }
          ];
        };

        testnet0 = {
          user = "byron";
          hostname = "198.244.164.100";
        };

        mainnet0 = {
          user = "byron";
          hostname = "51.89.218.19";
        };

        dev = {
          user = "byron";
          hostname = "185.48.176.109";
        };

        byron0 = {
          user = "byron";
          hostname = "65.108.122.69";
        };

        byron1 = {
          user = "admin";
          hostname = "65.108.64.117";
        };
      };
    };
  };
}
