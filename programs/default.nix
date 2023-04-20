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
    externalEditor = "${pkgs.neovide}/bin/neovide";
    extraConfig = {
      startup.queries = {
        placzynski-pawel_gmail-com = "folder:placzynski-pawel/Inbox";
        silquenarmo_gmail-com = "folder:silquenarmo/Inbox";
        p-placzynski_binarapps-com = "folder:p-placzynski-binarapps/Inbox";
        pawel-placzynski_byron-network = "folder:pawel-placzynski-byron/Inbox";
        pawel-placzynski_futurelearn-com = "folder:pawel-placzynski_futurelearn-com/Inbox";
      };
    };
  };

  afew = {
    enable = true;
    extraConfig = ''
      [SpamFilter]
      [KillThreadsFilter]
      [ListMailsFilter]
      [ArchiveSentMailsFilter]
      [FolderNameFilter]
      maildir_separator = /

      [MailMover]
      folders = placzynski-pawel/Inbox silquenarmo/Inbox p-placzynski-binarapps/Inbox pawel-placzynski-byron/Inbox pawel-placzynski_futurelearn-com/Inbox
      rename = true

      placzynski-pawel/Inbox = 'NOT tag:Inbox':"placzynski-pawel/[Gmail]/All Mail"
      silquenarmo/Inbox = 'NOT tag:Inbox':"silquenarmo/[Gmail]/All Mail"
      p-placzynski-binarapps/Inbox = 'NOT tag:Inbox':"p-placzynski-binarapps/[Gmail]/All Mail"
      pawel-placzynski-byron/Inbox = 'NOT tag:Inbox':"pawel-placzynski-byron/[Gmail]/All Mail"
      pawel-placzynski_futurelearn-com/Inbox = 'NOT tag:Inbox':"pawel-placzynski_futurelearn-com/[Gmail]/All Mail"
    '';
  };

  msmtp = {
    enable = true;
  };
}
