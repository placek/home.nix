{ config
, lib
, pkgs
, ...
}:
{
  config = {
    programs.fzf.enableFishIntegration = true;            # fuzzy finder
    programs.nix-index.enableFishIntegration = true;      # nix package search
    programs.zoxide.enableFishIntegration = true;         # directory navigation
    programs.nix-your-shell.enableFishIntegration = true; # nix shell management
    programs.lsd.enableFishIntegration = true;            # replacement for ls
    programs.carapace.enableFishIntegration = true;
    programs.mcfly.enableFishIntegration = true;
    programs.starship.enableFishIntegration = true;

    services.gpg-agent.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        bind ctrl-x echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
        bind ctrl-a fzf-cd-widget
        bind ctrl-z undo
        bind f11 accept-autosuggestion
      '';

      functions.fish_greeting.body = "";
      shellAbbrs = {
        j = "journalctl";
        s = "systemctl";

        sshh = "TERM=xterm-256color ssh";
        cdt = "cd (mktemp -d)";
      };
    };
  };
}
