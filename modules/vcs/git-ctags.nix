{ pkgs
, ...
}:
pkgs.writeShellScriptBin "git-ctags" ''
  set -e

  dir="$(git rev-parse --git-dir)"
  trap 'rm -f "$dir/$$.tags"' EXIT
  git ls-files | ctags --tag-relative -G -L - -f "$dir/$$.tags" 2> /dev/null
  mv "$dir/$$.tags" "$dir/tags"
''
