{ pkgs, ... }:
pkgs.writeShellScriptBin "git-ctags" ''
  #!/usr/bin/env bash
  set -e

  if [ -x ".git/hooks/ctags" ]; then
    .git/hooks/ctags
  else
    >&2 echo "git-ctags: no hook at .git/hooks/ctags exists"
  fi
''
