{ pkgs, ... }:
{
  home-manager.enable = true;
  qutebrowser = import ./qutebrowser;
  kitty = import ./kitty;
  git = import ./git;
  fish = import ./fish { inherit (pkgs) fetchFromGitHub; };
  gpg = import ./gpg;
  password-store = import ./password-store { inherit (pkgs) pass; };
  neovim = import ./neovim { inherit pkgs; };
}
