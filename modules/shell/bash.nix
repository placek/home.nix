{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.fzf.enableBashIntegration = true;
    programs.nix-index.enableBashIntegration = true;
    programs.zoxide.enableBashIntegration = true;
    programs.lsd.enableBashIntegration = true;
    programs.carapace.enableBashIntegration = true;
    programs.mcfly.enableBashIntegration = true;
    programs.starship.enableBashIntegration = true;

    programs.bash = {
      enable = true;

      shellAliases = {
        j = "journalctl";
        s = "systemctl";

        sshh = "TERM=xterm-256color ssh";
        cdt = "cd $(mktemp -d)";
      };
    };
  };
}
