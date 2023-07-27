{ config
, lib
, ...
}:
let
  sources = import ../../home.lock.nix;
  speak = import ./speak.nix { inherit (sources) pkgs; };
  summarize = import ./summarize.nix { inherit (sources) pkgs; };
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
    home.sessionVariables.EDENAI_API_KEY = (import ../../secrets).edenAI;

    programs.aria2.enable = true;
    programs.direnv.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.nix-index.enable = true;

    programs.bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };

    home.packages = with sources.pkgs; [
      speak
      summarize

      curl
      file
      go-jira
      imagemagick
      killall
      libinput
      mdcat
      openssl
      openvpn
      orca-c
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
