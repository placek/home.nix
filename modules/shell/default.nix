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
    ./nnn.nix
  ];

  config = {
    home.sessionVariables.SHELL = "fish";

    programs.fzf.enableFishIntegration = true;
    programs.nix-index.enableFishIntegration = true;

    services.gpg-agent.enableFishIntegration = true;

    programs.fzf.enable = true;
    programs.lsd.enable = true;
    programs.zoxide.enable = true;

    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./extraConfig;
    };
  };
}
