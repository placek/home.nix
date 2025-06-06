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
      interactiveShellInit = ''
        bind \ex echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
        bind \ec fzf-cd-widget
        bind \ez undo
        bind \eu togglecase_char
        bind f11 accept-autosuggestion

        set --universal pure_show_system_time true
        set --universal pure_color_primary yellow
        set --universal pure_color_success green
        set --universal pure_color_danger red
        set --universal pure_enable_nixdevshell true
        set --universal pure_color_nixdevshell_prefix brblack
        set --universal pure_symbol_nixdevshell_prefix '''
        set --universal pure_enable_git true
      '';
    };
  };
}
