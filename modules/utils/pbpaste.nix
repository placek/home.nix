{ pkgs
}:
pkgs.writeShellScriptBin "pbpaste" ''
  #!${pkgs.stdenv.shell}

  xclip -selection clipboard -o
''
