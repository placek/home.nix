let
  settings = import ../../settings;
  editor = "vim";
in
{
  enable = true;
  userName = settings.user.fullName;
  userEmail = settings.user.email;
  signing = {
    signByDefault = true;
    key = settings.key.sign;
  };
  aliases = {
    root = "rev-parse --show-toplevel";
    st = "status -sb";
    pu = "push --tags origin";
    cp = "cherry-pick";
    wip = "!bash -c 'git commit -m \"wip: \$(curl -Ls whatthecommit.com/index.txt)\"'";

    # add & commit
    a = "add";
    c = "commit";
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
    r = "restore";
    rs = "restore --staged";

    # reset
    r1 = "reset --soft @~1";
    r2 = "reset --soft @~2";
    r3 = "reset --soft @~3";
    rh1 = "reset --hard @~1";
    rh2 = "reset --hard @~2";
    rh3 = "reset --hard @~3";
  };
  ignores = [
    "*.key"
    "*.sql"
    "*~"
    ".DS_Store"
    ".authorized_keys"
    ".local.*"
    ".remote.compose"
    ".sw[op]"
    ".tags"
    "nohup.out"
  ];
  extraConfig = {
    commit.verbose = true;
    github.user = settings.user.name;
    apply.whitespace = "nowarn";
    rerere.enabled = 1;
    merge.tool = "vimdiff";
    difftool.prompt = false;
    mergetool.trustExitCode = true;
    mergetool.conflictstyle = "diff3";
    pull.ff = "only";
    difftool.trustExitCode = true;
    status.submoduleSummary = true;
    core = {
      editor = editor;
      attributesfile = "${settings.dirs.home}/.gitattributes_global";
      whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
    };
  };
}
