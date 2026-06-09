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
        shopt -s histappend
        shopt -s cmdhist
        export HISTIGNORE="ls:cd:pwd:exit:clear:history"
        export HISTCONTROL=ignoredups:erasedups
        export HISTTIMEFORMAT="%F %T "
        export HISTSIZE=100000
        export HISTFILESIZE=200000
        export PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
      '';

      shellAliases = {
        j = "journalctl";
        s = "systemctl";

        sshh = "TERM=xterm-256color ssh";
        cdt = "cd $(mktemp -d)";
      };
    };
  };
}
