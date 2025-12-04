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
    ./prompt.nix
  ];

  config = {
    home.sessionVariables.SHELL = "fish";

    programs.fzf.enableFishIntegration = true;            # fuzzy finder
    programs.nix-index.enableFishIntegration = true;      # nix package search
    programs.zoxide.enableFishIntegration = true;         # directory navigation
    programs.nix-your-shell.enableFishIntegration = true; # nix shell management
    programs.lsd.enable = true;
    programs.lsd.enableFishIntegration = true;            # replacement for ls
    programs.carapace.enable = true;                      # shell completion
    programs.carapace.enableFishIntegration = true;
    programs.mcfly.enable = true;                         # command history
    programs.mcfly.enableFishIntegration = true;
    programs.starship.enableFishIntegration = true;
    programs.zoxide.enable = true;

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
        dsp = "docker system prune";
        dspv = "docker system prune --volumes";
        dspa = "docker system prune --volumes --all";

        dcb = "docker compose build";
        dce = "docker compose exec";
        dca = "docker compose attach";
        dcr = "docker compose run --rm";
        dcu = "docker compose up --detach";
        dcl = "docker compose logs";
        dcd = "docker compose down --remove-orphans";
        dcdv = "docker compose down --remove-orphans --volumes";
        dcres = "docker compose restart";
        dcps = "docker compose ps";

        j = "journalctl";
        s = "systemctl";

        tt = "nc termbin.com 9999";
        tf = "nc oshi.at 7777";
        t = "tldr";

        sshh = "TERM=xterm-256color ssh";
        cdt = "cd (mktemp -d)";
      };
    };
  };
}
