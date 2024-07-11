{ config
, pkgs
, ...
}:
let
  plugins = pkgs.fetchFromGitHub {
    owner = "jarun";
    repo = "nnn";
    rev = "v4.0";
    sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
  };
in
{
  config.programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      D = "~/Documents";
      d = "~/Downloads";
      p = "~/Projects";
    };
    plugins.src = plugins + "/plugins";
    plugins.mappings = {
      z = "autojump";
      x = "togglex";
      r = "renamer";
      s = "suedit";
    };
  };
}
