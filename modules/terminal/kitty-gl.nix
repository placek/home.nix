{ pkgs
, glpkgs
, ...
}:
pkgs.writeShellScriptBin "kitty-gl" ''
  #!${pkgs.stdenv.shell}
  ${glpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"
''
