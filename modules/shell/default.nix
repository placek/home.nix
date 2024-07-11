{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    shellExec = mkOption {
      type = types.str;
      default = "${pkgs.fish}/bin/fish";
      description = "Shell executable.";
      readOnly = true;
    };
  };

  imports = [
    ./aliases.nix
    ./plugins.nix
  ];

  config = {
    home.sessionVariables.SHELL = "fish";

    programs.fzf.enableFishIntegration = true;
    programs.nix-index.enableFishIntegration = true;

    services.gpg-agent.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./extraConfig;
    };
  };
}
