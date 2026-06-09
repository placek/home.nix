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
    programs.bash.enableCompletion = true;

    home.file.".inputrc".text = ''
      set completion-ignore-case on
      set show-all-if-ambiguous on
      set colored-stats on
      set menu-complete-display-prefix on
    '';

    programs.bash = {
      enable = true;

      initExtra = ''
        shopt -s histappend
        shopt -s cmdhist
        shopt -s autocd
        shopt -s cdspell
        shopt -s dirspell
        shopt -s globstar
        shopt -s extglob
        shopt -s nocaseglob
        shopt -s dotglob

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
