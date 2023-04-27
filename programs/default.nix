{ pkgs, settings, ... }:
{
  home-manager.enable = true;

  astroid = import ./astroid;
  fish = import ./fish { inherit (pkgs) fetchFromGitHub; inherit settings; };
  gh = import ./gh;
  git = import ./git { inherit settings; };
  gpg = import ./gpg { inherit settings; };
  kitty = import ./kitty;
  neovim = import ./neovim { inherit pkgs; };
  password-store = import ./password-store { inherit (pkgs) pass; inherit settings; };
  qutebrowser = import ./qutebrowser { inherit pkgs settings; };
  ssh = import ./ssh;

  aria2 = { enable = true; };
  direnv = { enable = true; };
  htop = { enable = true; };
  jq = { enable = true; };
  lsd = { enable = true; };
  mbsync = { enable = true; };
  msmtp = { enable = true; };
  nnn = { enable = true; };

  bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  broot = {
    enable = true;
    enableFishIntegration = true;
  };

  fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  notmuch = {
    enable = true;
    hooks.postNew = ''
      ${pkgs.notmuch}/bin/notmuch tag -inbox -- tag:inbox
      ${pkgs.notmuch}/bin/notmuch tag -Inbox -- not folder:placzynski/Inbox and not folder:silquenarmo/Inbox and not folder:binarapps/Inbox and not folder:byron/Inbox and not folder:futurelearn/Inbox and tag:Inbox
    '';
  };
}
