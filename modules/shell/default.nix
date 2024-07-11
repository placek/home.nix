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

    programs.fzf.enable = true;
    programs.lsd.enable = true;
    programs.zoxide.enable = true;

    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      bookmarks = { D = "~/Documents"; d = "~/Downloads"; p = "~/Projects"; };
      plugins = {
        src = (pkgs.fetchFromGitHub { owner = "jarun"; repo = "nnn"; rev = "v4.0"; sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k="; }) + "/plugins";
        mappings = { z = "autojump"; x = "togglex"; r = "renamer"; s = "suedit"; };
      };
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./extraConfig;
    };
  };
}
