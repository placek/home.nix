{ config, lib, ... }:
let
  sources = import ../../home.lock.nix;
  inherit (sources) pkgs;
in
{
  options = with lib; {
    vcs.name = mkOption {
      type = types.str;
      default = config.home.username;
      example = "John Smith";
      description = mdDoc "Author/commiter full name.";
    };

    vcs.email = mkOption {
      type = types.str;
      example = "john-smith@example.com";
      description = mdDoc "Author/commiter email.";
    };

    vcs.login = mkOption {
      type = types.str;
      example = "john-smith";
      description = mdDoc "Author/commiter login.";
    };

    vcs.signKey = mkOption {
      type = types.str;
      example = "AAAAssfGFFsgdsgERgTT35qfgewhtu12345qgaqe4…";
      description = mdDoc "GPG sign key to sign any verifiable VCS content.";
    };

    vcs.gitAttributesFilePath = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.gitattributes_global";
      example = "${config.home.homeDirectory}/.gitattributes_global";
      description = mdDoc "A path to git attributes file.";
    };

    editor = mkOption {
      type = types.str;
      default = "vim";
      example = "vim";
      description = mdDoc "Editor binary name.";
    };

    difftool = mkOption {
      type = types.str;
      default = "vimdiff";
      example = "vimdiff";
      description = mdDoc "Diff tool binary name.";
    };
  };

  config = {
    home.packages = with pkgs; [
      (import ./git-ctags.nix { inherit pkgs; })
      git-crypt
    ];

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = config.editor;
        prompt = "enabled";
        aliases.co = "pr checkout";
        aliases.pv = "pr view";
      };
    };

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
        core.editor = config.editor;
        core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        difftool.prompt = false;
        difftool.trustExitCode = true;
        fetch.prune = true;
        github.user = config.vcs.login;
        merge.tool = config.difftool;
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
