{ config
, lib
, pkgs
, ...
}:
let
  speak = import ./speak.nix { inherit pkgs; };
  image = import ./image.nix { inherit pkgs; };
  video = import ./video.nix { inherit pkgs; };
  audio = import ./audio.nix { inherit pkgs; };
  pbcopy = import ./pbcopy.nix { inherit pkgs; };
  pbpaste = import ./pbpaste.nix { inherit pkgs; };
  vasm = import ./vasm.nix { inherit pkgs; };
  dcc6502 = import ./dcc6502.nix { inherit pkgs; };
  minipro = import ./minipro.nix { inherit pkgs; };
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
  };

  config = {
    programs.aria2.enable = true;
    programs.direnv.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.nix-index.enable = true;

    programs.bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };

    home.packages = with pkgs; [
      audio
      image
      pbcopy
      pbpaste
      speak
      video

      # dcc6502
      # minipro
      # vasm
      # pkgsCross.avr.buildPackages.gcc

      ansible
      avrdude
      bash
      bind
      cbqn
      croc
      cryptsetup
      curl
      docker-compose
      entr
      ffmpeg-full
      file
      ghostscript
      go-jira
      htmlq
      imagemagick
      jmespath
      jmtpfs
      killall
      libinput
      mdcat
      netpbm
      ngrep
      ngrok
      niv
      nix-direnv-flakes
      nix-prefetch-git
      openssl
      openvpn
      orca-c
      qmk
      rclone
      rlwrap
      rnix-lsp
      rpi-imager
      rsync
      sox
      sshfs
      timidity
      tiv
      tmate
      unrar
      unzip
      usbutils
      vagrant
      wally-cli
      wget
      wrk2
      yq
    ];
  };
}
