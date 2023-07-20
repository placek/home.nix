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
      description = mdDoc "Shell executable.";
      readOnly = true;
    };
  };

  config = {
    home.sessionVariables.SHELL = "fish";

    programs.broot.enableFishIntegration = true;
    programs.fzf.enableFishIntegration = true;
    programs.nix-index.enableFishIntegration = true;

    services.gpg-agent.enableFishIntegration = true;

    programs.fzf.enable = true;
    programs.lsd.enable = true;
    programs.nnn.enable = true;

    programs.fish = {
      enable = true;
      shellAliases = import ./aliases.nix;
      shellAbbrs = import ./abbrs.nix;
      functions = import ./functions.nix;
      plugins = import ./plugins.nix { inherit (pkgs) fetchFromGitHub; };
      interactiveShellInit = builtins.readFile ./extraConfig;
    };
  };
}
