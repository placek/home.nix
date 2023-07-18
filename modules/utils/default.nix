{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  speak = import ./speak.nix { inherit (sources) pkgs; };
in
{
  options = with lib; {
    fileManagerExec = mkOption {
      type = types.str;
      default = "${sources.pkgs.nnn}/bin/nnn";
      description = mdDoc "File manager executable.";
      readOnly = true;
    };

    downloaderExec = mkOption {
      type = types.str;
      default = "${sources.pkgs.aria}/bin/aria2c";
      description = mdDoc "Downloader executable.";
      readOnly = true;
    };

    ytDownloaderExec = mkOption {
      type = types.str;
      default = "${sources.pkgs.yt-dlp}/bin/yt-dlp";
      description = mdDoc "YouTube downloader executable.";
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

    home.packages = with sources.pkgs; [
      speak

      curl
      file
      go-jira
      imagemagick
      killall
      libinput
      mdcat
      openssl
      openvpn
      rlwrap
      rnix-lsp
      sox
      unrar
      unzip
      wget
      yq
    ];
  };
}
