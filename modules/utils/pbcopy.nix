{ pkgs
}:
pkgs.writeShellScriptBin "pbcopy" ''
  xclip -selection clipboard
''
