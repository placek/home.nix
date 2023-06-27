{ pkgs, settings, ... }:
{
  home-manager.enable = true;

  aria2.enable = true;
  broot.enable = true;
  direnv.enable = true;
  fzf.enable = true;
  htop.enable = true;
  jq.enable = true;
  lsd.enable = true;
  nix-index.enable = true;
  nnn.enable = true;

  bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };
}
