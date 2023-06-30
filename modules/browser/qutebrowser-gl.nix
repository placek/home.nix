{ pkgs, glpkgs, ... }:
pkgs.writeShellScriptBin "qutebrowser-gl" ''
  #!/usr/bin/env bash
  export ALSA_PLUGIN_DIR=${pkgs.pipewire.lib}/lib/alsa-lib
  ${glpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser $@
''
