{ pkgs
, ...
}:
pkgs.writeShellScriptBin "git-ctags" ''
  dir="$(git rev-parse --show-toplevel 2> /dev/null)"

  if [ -z "$dir" ]; then
    echo "Not in a git repository" >&2
    exit 1
  fi

  if [ -x "$dir/.git/hooks/ctags" ]; then
    exec "$dir/.git/hooks/ctags"
  else
    git ls-files | ctags --tag-relative -G -L - -f "$dir/.git/tags" 2> /dev/null
  fi
''
