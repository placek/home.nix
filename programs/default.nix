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
    hooks.postNew = ''
      ${pkgs.notmuch}/bin/notmuch tag -inbox -- tag:inbox
      ${pkgs.notmuch}/bin/notmuch tag -Inbox -- not folder:placzynski/Inbox and not folder:silquenarmo/Inbox and not folder:binarapps/Inbox and not folder:byron/Inbox and not folder:futurelearn/Inbox and tag:Inbox
    '';
  };

  astroid = {
    enable = true;
    externalEditor = ''
      kitty vim "+set ft=mail" "+set fileencoding=utf-8" "+set ff=unix" "+set enc=utf-8" "+set fo+=w" %1
    '';
    extraConfig = {
      startup.queries = {
        placzynski = "folder:placzynski/Inbox";
        silquenarmo = "folder:silquenarmo/Inbox";
        binarapps = "folder:binarapps/Inbox";
        byron = "folder:byron/Inbox";
        futurelearn = "folder:futurelearn/Inbox";
      };
    };
  };

  msmtp = {
    enable = true;
  };
}
