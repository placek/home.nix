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
      initExtra = ''
        source ${pkgs.blesh}/share/blesh/ble.sh
        ble-face -s auto_complete fg=240
        ble-bind -m auto_complete -f f11 auto_complete/insert
        ble-bind -m emacs -f f11 complete
        bind '"\C-z": undo'
      '';

      shellAliases = {
        dsp = "docker system prune";
        dspv = "docker system prune --volumes";
        dspa = "docker system prune --volumes --all";

        dcb = "docker compose build";
        dce = "docker compose exec";
        dca = "docker compose attach";
        dcr = "docker compose run --rm";
        dcu = "docker compose up --detach --remove-orphans";
        dcl = "docker compose logs";
        dcd = "docker compose down --remove-orphans";
        dcdv = "docker compose down --remove-orphans --volumes";
        dcres = "docker compose restart";
        dcps = "docker compose ps";

        j = "journalctl";
        s = "systemctl";

        t = "tldr";

        sshh = "TERM=xterm-256color ssh";
        cdt = "cd $(mktemp -d)";
      };
    };
  };
}
