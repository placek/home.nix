{ config
, lib
, pkgs
, ...
}:
let
  git-ctags = pkgs.writeShellScriptBin "git-ctags" ''
    dir="$(${config.vcsExec} rev-parse --show-toplevel 2> /dev/null)"

    if [ -z "$dir" ]; then
      echo "Not in a git repository" >&2
      exit 1
    fi

    if [ -x "$dir/.git/hooks/ctags" ]; then
      exec "$dir/.git/hooks/ctags"
    else
      ${config.vcsExec} ls-files | ${config.ctagsExec} --tag-relative -G -L - -f "$dir/.git/tags" 2> /dev/null
    fi
  '';
in
{
  options.ctagsExec = with lib; mkOption {
    type = types.str;
    default = "${pkgs.universal-ctags}/bin/ctags";
    description = "cTags executable.";
    readOnly = true;
  };

  config.home.packages = [ git-ctags ];
}
