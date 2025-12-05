{ config
, ...
}:
{
  config.programs.git.settings = {
    apply.whitespace = "nowarn";
    commit.verbose = true;
    core.attributesfile = config.vcs.gitAttributesFilePath;
    core.editor = config.editorExec;
    core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
    core.default = "origin/master";
    difftool.prompt = false;
    difftool.trustExitCode = true;
    fetch.prune = true;
    github.user = config.vcs.login;
    merge.tool = config.difftoolExec;
    mergetool.conflictstyle = "diff3";
    mergetool.trustExitCode = true;
    pull.ff = "only";
    push.autoSetupRemote = true;
    rebase.autosquash = true;
    rerere.enabled = 1;
    status.submoduleSummary = true;
  };
}
