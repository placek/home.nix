{ fetchFromGitHub, settings, ... }:
let
  editor = "vim";
in
{
  enable = true;

  shellAliases = {
    ls = "lsd --icon-theme unicode --hyperlink auto";
    tree = "lsd --icon-theme unicode --tree --hyperlink auto";
    sshh = "TERM=xterm-256color ssh";
    cdt = "cd (mktemp -d)";
  };

  shellAbbrs = {
    dsp = "docker system prune";
    dspv = "docker system prune --volumes";
    dspa = "docker system prune --volumes --all";

    dcb = "docker-compose -f .local.compose build";
    dcr = "docker-compose -f .local.compose run --rm";
    dcu = "docker-compose -f .local.compose up -d";
    dcl = "docker-compose -f .local.compose logs";
    dcd = "docker-compose -f .local.compose down --remove-orphans";
    dcres = "docker-compose -f .local.compose restart";
    dcps = "docker-compose -f .local.compose ps";

    j = "journalctl";
    s = "systemctl";
    tt = "nc termbin.com 9999";
    tf = "nc oshi.at 7777";

    ":q" = "read_confirm && exit";
    ":q!" = "exit";
    ":w" = "git commit -p";
  };
  functions = {
    fish_greeting = {
      description = "Greeting to show when starting a fish shell.";
      body = "";
    };
    fish_right_prompt = {
      description = "Right prompt.";
      body = ''
        printf "%s%s %s" (_pure_set_color $pure_color_git_branch) $pure_symbol_reverse_prompt $IN_NIX_SHELL
      '';
    };
    read_confirm = {
      description = "Confirm action.";
      body = ''
        while true
          read -l -P "Are you sure? [y/N] " confirm
          switch $confirm
            case Y y T t
              return 0
            case "*"
              return 1
          end
        end
      '';
    };
  };

  plugins = [
    {
      name = "z";
      src = fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
        sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      };
    }
    {
      name = "pure";
      src = fetchFromGitHub {
        owner = "pure-fish";
        repo = "pure";
        rev = "1c1f5b4d1d3fa36162186aa0aac295f59efe22bc";
        sha256 = "sha256-ec1ZAjIGn6xYMh+3kyQP8HYUti8iFXsyzTJ19tU8T84=";
      };
    }
  ];

  interactiveShellInit = ''
    bind \ex echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
    bind \ec fzf-cd-widget
    bind \ef fzf-file-widget
    bind \er fzf-history-widget

    set --universal pure_enable_single_line_prompt true
    set --universal pure_show_system_time true
    set --universal pure_show_system_time true
    set --universal pure_color_primary yellow
    set --universal pure_color_success green
    set --universal pure_color_danger red
  '';
}
