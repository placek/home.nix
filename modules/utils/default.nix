{ config
, lib
, pkgs
, ...
}:
let
  sources = import ../../home.lock.nix;
  custom-nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
  speak = import ./speak.nix { inherit pkgs; };
in
{
  options = with lib; {
    fileManagerExec = mkOption {
      type = types.str;
      default = "${pkgs.nnn}/bin/nnn";
      description = mdDoc "File manager executable.";
      readOnly = true;
    };

    downloaderExec = mkOption {
      type = types.str;
      default = "${pkgs.aria}/bin/aria2c";
      description = mdDoc "Downloader executable.";
      readOnly = true;
    };

    ytDownloaderExec = mkOption {
      type = types.str;
      default = "${pkgs.yt-dlp}/bin/yt-dlp";
      description = mdDoc "YouTube downloader executable.";
      readOnly = true;
    };

    menuExec = mkOption {
      type = types.str;
      default = "${pkgs.xprompt}/bin/xprompt";
      description = mdDoc "GUI menu executable.";
      readOnly = true;
    };
  };

  config = {
    programs.aria2.enable = true;
    programs.direnv.enable = true;
    programs.fzf.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.lsd.enable = true;
    programs.nix-index.enable = true;
    programs.nnn.enable = true;

    programs.bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };

    home.packages = with pkgs; [
      sources.glpkgs.nixGLIntel

      custom-nerdfonts
      speak

      ubuntu_font_family
      google-fonts
      font-awesome

      curl
      file
      imagemagick
      killall
      libinput
      xf86_input_wacom
      mdcat
      openssl
      openvpn
      qtpass
      rlwrap
      rnix-lsp
      sox
      unrar
      unzip
      wget
      wl-clipboard
      yq
    ];
  };
}
