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
    adi = "add -i";
    amend = "commit --amend --no-edit";
    co = "checkout";
    com = "commit -m";
    diffc = "diff --cached";
    info = "for-each-ref --format='%(color:yellow)%(committerdate:iso8601) %(color:blue)%(objectname:short) %(color:magenta)%(authorname) %(color:green)%(refname:short) %(color:reset)%(contents:subject)' --sort -committerdate";
    l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    pu = "push --tags origin";
    purge = "reset --hard";
    root = "rev-parse --show-toplevel";
    st = "status -sb";
    stashp = "stash push -p";
  };
  ignores = [
    "*~"
    ".DS_Store"
    "*.sql"
    ".tags"
    ".sw[op]"
    "*.key"
    ".local.dev.env"
    ".local.test.env"
    ".local.compose"
    ".local.image"
    ".local.nix"
    ".local.entrypoint"
    ".remote.compose"
    ".authorized_keys"
  ];
  extraConfig = {
    github.user = settings.user.name;
    apply.whitespace = "nowarn";
    rerere.enabled = 1;
    format.pretty = "%C(yellow)%h%Creset %C(magenta)%cd%Creset %d %s";
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
