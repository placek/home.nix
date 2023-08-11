{
  root = "utls root";
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
  l = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate";
  ls = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
  ll = "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --numstat";
  info = "for-each-ref --format='%(color:yellow)%(committerdate:iso8601) %(color:blue)%(objectname:short) %(color:magenta)%(authorname) %(color:green)%(refname:short) %(color:reset)%(contents:subject)' --sort -committerdate";

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
}
