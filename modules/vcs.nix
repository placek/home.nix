{ config, pkgs, ... }:
let
  sources = import ../home.lock.nix;
  settings = import ../settings;
  inherit (settings.defaults) editor difftool;
in
{
  home.packages = with pkgs; [
    git-crypt

    (writeShellScriptBin "git-ctags" ''
      #!/usr/bin/env bash
      set -e

      if [ -x ".git/hooks/ctags" ]; then
        .git/hooks/ctags
      else
        >&2 echo "git-ctags: no hook at .git/hooks/ctags exists"
      fi
    '')
  ];

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = editor;
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  programs.git = {
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
      pushwip = "!bash -c 'git commit -p -m \"wip: \$(curl -Ls whatthecommit.com/index.txt)\"; git push -f; git reset --mixed @~1'";
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
    };
    ignores = [
      "*.key"
      "*.sql"
      "*~"
      ".DS_Store"
      ".authorized_keys"
      ".local.*"
      ".remote.*"
      ".sw[op]"
      ".tags"
      "nohup.out"
    ];
    extraConfig = {
      apply.whitespace = "nowarn";
      commit.verbose = true;
      core.attributesfile = "${settings.dirs.home}/.gitattributes_global";
      core.editor = editor;
      core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      difftool.prompt = false;
      difftool.trustExitCode = true;
      fetch.prune = true;
      github.user = settings.user.name;
      merge.tool = difftool;
      mergetool.conflictstyle = "diff3";
      mergetool.trustExitCode = true;
      pull.ff = "only";
      push.autoSetupRemote = true;
      rebase.autosquash = true;
      rerere.enabled = 1;
      status.submoduleSummary = true;
    };
  };
}
