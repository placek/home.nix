{ pkgs
}:
pkgs.writeShellScriptBin "pbcopy" ''
  #!${pkgs.stdenv.shell}

  xclip -selection clipboard
''
