{ pkgs
, glpkgs
, ...
}:
pkgs.writeShellScriptBin "qutebrowser-gl" ''
  #!${pkgs.stdenv.shell}
  export ALSA_PLUGIN_DIR=${pkgs.pipewire.lib}/lib/alsa-lib
  ${glpkgs.nixGLIntel}/bin/nixGLIntel qutebrowser $@
''
