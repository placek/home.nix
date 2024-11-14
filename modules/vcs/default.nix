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

  imports = [
    ./git-ctags.nix
    ./gh.nix
    ./aliases.nix
    ./ignores.nix
    ./settings.nix
  ];

  config = {
    home.packages = with pkgs; [
      git-crypt
      git-absorb
    ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userName = config.vcs.name;
      userEmail = config.vcs.email;
      lfs.enable = true;
      signing.signByDefault = true;
      signing.key = config.vcs.signKey;
    };
  };
}
