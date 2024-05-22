{ config
, lib
, pkgs
, ...
}:
{
  options = with lib; {
    vcsExec = mkOption {
      type = types.str;
      default = "${pkgs.git}/bin/git";
      description = "VCS executable.";
      readOnly = true;
    };

    vcs.name = mkOption {
      type = types.str;
      default = config.home.username;
      example = "John Smith";
      description = "Author/commiter full name.";
    };

    vcs.email = mkOption {
      type = types.str;
      example = "john-smith@example.com";
      description = "Author/commiter email.";
    };

    vcs.login = mkOption {
      type = types.str;
      example = "john-smith";
      description = "Author/commiter login.";
    };

    vcs.signKey = mkOption {
      type = types.str;
      example = "AAAAssfGFFsgdsgERgTT35qfgewhtu12345qgaqe4…";
      description = "GPG sign key to sign any verifiable VCS content.";
    };

    vcs.gitAttributesFilePath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.gitattributes_global";
      example = "${config.home.homeDirectory}/.gitattributes_global";
      description = "A path to git attributes file.";
    };
  };

  config = {
    home.packages = with pkgs; [
      (import ./git-ctags.nix { inherit pkgs; })
      git-crypt
      git-absorb
    ];

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = config.editorExec;
        prompt = "enabled";
        aliases.current = "pr view --comments";
      };
    };

    programs.gh-dash.enable = true;

    programs.git = {
      enable = true;
      userName = config.vcs.name;
      userEmail = config.vcs.email;
      signing.signByDefault = true;
      signing.key = config.vcs.signKey;
      aliases = import ./aliases.nix;
      ignores = import ./ignores.nix;
      extraConfig = {
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
    };
  };
}
