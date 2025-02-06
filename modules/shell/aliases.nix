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

    syncp = "rsync -avz --progress ${config.projectsDirectory} placek@placki.cloud:/var/projects/";

    j = "journalctl";
    s = "systemctl";

    tt = "nc termbin.com 9999";
    tf = "nc oshi.at 7777";

    sshh = "TERM=xterm-256color ssh";
    cdt = "cd (mktemp -d)";
  };
}
