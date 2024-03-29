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
  psalmus = import ./psalmus.nix { inherit pkgs; };
  vasm = import ./vasm.nix { inherit pkgs; };
  dcc6502 = import ./dcc6502.nix { inherit pkgs; };
  minipro = import ./minipro.nix { inherit pkgs; };
  jarvis = import ./jarvis.nix { inherit pkgs; };
  gh-pr = import ./gh-pr.nix { inherit pkgs; };
in
{
  options = with lib; {
    fileManagerExec = mkOption {
      type = types.str;
      default = "${pkgs.nnn}/bin/nnn";
      description = "File manager executable.";
      readOnly = true;
    };

    downloaderExec = mkOption {
      type = types.str;
      default = "${pkgs.aria}/bin/aria2c";
      description = "Downloader executable.";
      readOnly = true;
    };

    ytDownloaderExec = mkOption {
      type = types.str;
      default = "${pkgs.yt-dlp}/bin/yt-dlp";
      description = "YouTube downloader executable.";
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
      jarvis
      image
      pbcopy
      pbpaste
      psalmus
      speak
      video
      gh-pr

      elixir

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
      fd
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
      lightburn
      mdcat
      nap
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
      ripgrep
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
      uucp
      vagrant
      wally-cli
      wget
      wrk2
      yq
    ];
  };
}
