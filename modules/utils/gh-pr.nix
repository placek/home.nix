{ pkgs
}:
pkgs.writeShellScriptBin "gh-pr" ''
  issue=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD | ${pkgs.gnused}/bin/sed -n 's@.*/\([[:digit:]]\+\).*@\1@p')
  eval $(${pkgs.gh}/bin/gh issue view $issue --json number,title,milestone --jq "\"${pkgs.gh}/bin/gh pr create -w -a '@me' -t '[#\\(.number)] \\(.title)' -m '\\(.milestone.title)' -F -\"")
''
