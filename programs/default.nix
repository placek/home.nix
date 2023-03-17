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
}
