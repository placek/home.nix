{ pkgs, glpkgs, ... }:
pkgs.writeShellScriptBin "kitty-gl" ''
  #!/usr/bin/env bash
  ${glpkgs.nixGLIntel}/bin/nixGLIntel kitty "$@"
''
