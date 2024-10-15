{ config
, pkgs
, ...
}:
let
  autojump = pkgs.writeScriptBin "autojump" ''
    odir="$(zoxide query -i --)"
    printf "%s" "0c$odir" > "$NNN_PIPE"
  '';
  icat = pkgs.writeScriptBin "icat" ''
    kitty +kitten icat --silent --scale-up "$1"
    read -p "Press any key to continue…" -n1 -s
  '';
  suedit = pkgs.writeScriptBin "suedit" ''
    sudo -E "$EDITOR" "$1"
  '';
  plugins = pkgs.buildEnv {
    name = "nnn-plugins";
    paths = [ autojump icat suedit ];
  };
  d = c: builtins.trace c c;
in
{
  config.programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      D = "~/Documents";
      d = "~/Downloads";
      p = config.projectsDirectory;
    };
    plugins.src = (d "${plugins}") + "/bin";
    plugins.mappings = {
      z = "autojump";
      p = "icat";
      s = "suedit";
    };
  };
}
