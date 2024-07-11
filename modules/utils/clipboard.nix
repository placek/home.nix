{ config
, pkgs
, ...
}:
let
  pbcopy = pkgs.writeShellScriptBin "pbcopy" "${pkgs.xclip}/bin/xclip -selection clipboard";
  pbpaste = pkgs.writeShellScriptBin "pbpaste" "${pkgs.xclip}/bin/xclip -selection clipboard -o";
in
{
  config.home.packages = [ pbcopy pbpaste ];
}
