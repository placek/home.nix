{ pkgs
}:
pkgs.writeShellScriptBin "pbpaste" ''
  xclip -selection clipboard -o
''
