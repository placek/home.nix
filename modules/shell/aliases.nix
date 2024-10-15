{ config
, ...
}:
{
  config.programs.fish.shellAliases = {
    ls = "lsd --icon-theme unicode --hyperlink auto";
    tree = "lsd --icon-theme unicode --tree --hyperlink auto";
  };
  config.programs.fish.shellAbbrs = {
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

    syncp = "rsync -avz --progress /home/placek/Projects/ placek@placki.cloud:/var/projects/";

    j = "journalctl";
    s = "systemctl";

    tt = "nc termbin.com 9999";
    tf = "nc oshi.at 7777";

    sshh = "TERM=xterm-256color ssh";
    cdt = "cd (mktemp -d)";
  };
}
