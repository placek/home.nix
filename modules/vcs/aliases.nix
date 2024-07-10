{ config
, ...
}:
{
  config.programs.git.aliases = {
    root = "rev-parse --show-toplevel";
    changes = "log origin/HEAD..";
    ch = "l origin/HEAD..";
    st = "status -sb";
    pu = "push --tags origin";
    cp = "cherry-pick";
    wip = "!bash -c 'git commit --no-verify -m \"wip: \$(curl -Ls whatthecommit.com/index.txt)\"'";
    mrg = "merge --commit --edit";

    # add & commit
    a = "add";
    c = "commit";
    coc = "commit -p -C ORIG_HEAD";
    adi = "add -i";
    com = "commit -m";
    coi = "commit -p";
    con = "commit -n";
    amend = "commit --amend --no-edit";

    # diff
    diffc = "diff --cached";
    diffw = "diff --word-diff=color";
    diffwc = "diff --cached --word-diff=color";
    difft = "difftool";

    # checkout
    co = "checkout";
    cob = "checkout -B";

    # log
    l = "log --graph --pretty=format:'%C(yellow)%h %C(red)%d%C(reset) %s %C(green)%cr %C(blue)%an%C(reset)' --abbrev-commit";
    ll = "log --pretty=format:'%C(yellow)%h %C(red)%d%C(reset) %s %C(green)%cr %C(blue)%an%C(reset)' --decorate --numstat";
    info = "for-each-ref --format='%C(green)%(committerdate:iso8601) %C(yellow)%(objectname:short) %C(blue)%(authorname) %C(red)%(refname:short) %C(reset)%(contents:subject)' --sort -committerdate";

    # restore
    undo = "restore";
    undos = "restore --staged";

    # reset
    rs1 = "reset --soft @~1";
    rs2 = "reset --soft @~2";
    rs3 = "reset --soft @~3";
    rh1 = "reset --hard @~1";
    rh2 = "reset --hard @~2";
    rh3 = "reset --hard @~3";
    rm1 = "reset --mixed @~1";
    rm2 = "reset --mixed @~2";
    rm3 = "reset --mixed @~3";
  };
}
