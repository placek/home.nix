{ fetchFromGitHub, ... }:
let
  settings = import ../../settings;
  editor = "vim";
in
{
  enable = true;

  shellAliases = {
    ls = "lsd --icon-theme unicode --hyperlink auto";
    tree = "lsd --icon-theme unicode --tree --hyperlink auto";
    sshh = "TERM=xterm-256color ssh";
    cdt = "cd (mktemp -d)";
    icat = "kitty +kitten icat";
  };

  shellAbbrs = {
    dsp = "docker system prune";
    dspv = "docker system prune --volumes";
    dspa = "docker system prune --volumes --all";
    dcb = "docker-compose build";
    dcr = "docker-compose run --rm";
    dcu = "docker-compose up -d";
    dcl = "docker-compose logs";
    dcd = "docker-compose down --remove-orphans";
    dcres = "docker-compose restart";
    dcps = "docker-compose ps";

    lcb = "docker-compose -f .local.compose build";
    lcr = "docker-compose -f .local.compose run --rm";
    lcrt = "docker-compose -f .local.compose run --rm test";
    lcrw = "docker-compose -f .local.compose run --rm web";
    lcu = "docker-compose -f .local.compose up -d";
    lcl = "docker-compose -f .local.compose logs";
    lcd = "docker-compose -f .local.compose down --remove-orphans";
    lcres = "docker-compose -f .local.compose restart";
    lcps = "docker-compose -f .local.compose ps";

    tcb = "docker-compose -f .local.compose.test build";
    tcr = "docker-compose -f .local.compose.test run --rm";
    tcrt = "docker-compose -f .local.compose.test run --rm test";
    tcrw = "docker-compose -f .local.compose.test run --rm web";
    tcu = "docker-compose -f .local.compose.test up -d";
    tcl = "docker-compose -f .local.compose.test logs";
    tcd = "docker-compose -f .local.compose.test down --remove-orphans";
    tcres = "docker-compose -f .local.compose.test restart";
    tcps = "docker-compose -f .local.compose.test ps";

    j = "journalctl";
    s = "systemctl";
    tt = "nc termbin.com 9999";
    tf = "nc oshi.at 7777";
  };
  functions = {
    fish_greeting = {
      description = "Greeting to show when starting a fish shell";
      body = "";
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
      name = "fzf";
      src = fetchFromGitHub {
        owner = "PatrickF1";
        repo = "fzf.fish";
        rev = "63c8f8e65761295da51029c5b6c9e601571837a1";
        sha256 = "sha256-i9FcuQdmNlJnMWQp7myF3N0tMD/2I0CaMs/PlD8o1gw=";
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
    eval (direnv hook fish)

    bind \ec echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
    bind \cl '__fish_list_current_token'

    set --universal pure_enable_single_line_prompt true
    set --universal pure_show_system_time true
    set --universal pure_show_system_time true
    set --universal pure_color_primary yellow
    set --universal pure_color_success green
    set --universal pure_color_danger red
  '';
}
