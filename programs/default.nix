{ pkgs, ... }:
{
  home-manager.enable = true;

  fish = import ./fish { inherit (pkgs) fetchFromGitHub; };
  git = import ./git;
  gpg = import ./gpg;
  kitty = import ./kitty;
  neovim = import ./neovim { inherit pkgs; };
  password-store = import ./password-store { inherit (pkgs) pass; };
  qutebrowser = import ./qutebrowser;
  ssh = import ./ssh;

  aria2 = {
    enable = true;
  };

  bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  broot = {
    enable = true;
    enableFishIntegration = true;
  };

  direnv = {
    enable = true;
  };

  fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "vim";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  htop = {
    enable = true;
  };

  jq = {
    enable = true;
  };

  lsd = {
    enable = true;
  };

  nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  nnn = {
    enable = true;
  };

  mbsync = {
    enable = true;
  };

  notmuch = {
    enable = true;
  };

  astroid = {
    enable = true;
    externalEditor = "vim";
    extraConfig = {
      startup.queries.inbox_silquenarmo = "folder:silquenarmo/Inbox";
      startup.queries.inbox_placzynski-pawel = "folder:placzynski-pawel/Inbox";
      startup.queries.inbox_p-placzynski-binarapps = "folder:p-placzynski-binarapps/Inbox";
    };
  };

  msmtp = {
    enable = true;
  };
}
