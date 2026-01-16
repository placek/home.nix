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
in
{
  config.programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      b = config.home.homeDirectory;
      D = config.documentsDirectory;
      d = config.downloadsDirectory;
      p = config.projectsDirectory;
      m = "${config.home.homeDirectory}/Media";
    };
    plugins.src = "${plugins}/bin";
    plugins.mappings = {
      z = "autojump";
      p = "icat";
      s = "suedit";
    };
  };
}
