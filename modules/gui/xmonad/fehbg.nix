{ config
, pkgs
, ...
}:
pkgs.writeShellScriptBin "fehbg" ''
  #!${pkgs.stdenv.shell}

  ${pkgs.feh}/bin/feh --no-fehbg --bg-fill --randomize ${config.gui.wallpapersDirectory}/*
''
