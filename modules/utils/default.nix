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
  pbcopy = pkgs.writeShellScriptBin "pbcopy" "xclip -selection clipboard";
  pbpaste = pkgs.writeShellScriptBin "pbpaste" "xclip -selection clipboard -o";
  psalmus = import ./psalmus.nix { inherit pkgs; };
  vasm = import ./vasm.nix { inherit pkgs; };
  dcc6502 = import ./dcc6502.nix { inherit pkgs; };
  minipro = import ./minipro.nix { inherit pkgs; };
  tertius = import ./tertius.nix { inherit pkgs; inherit (config) browserExec; };
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
    programs.bat.config.theme = "gruvbox-dark";
    programs.bat.enable = true;
    programs.direnv.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.nix-index.enable = true;

    home.packages = with pkgs; [
      audio
      tertius
      image
      pbcopy
      pbpaste
      psalmus
      speak
      video

      dcc6502           # 6502 disassembler
      minipro           # EEPROM programmer
      vasm              # 6502 assembler
      # pkgsCross.avr.buildPackages.gcc

      ansible           # manage remote machines
      avrdude           # program AVR microcontrollers
      bash              # shell
      bind              # DNS server
      cbqn              # BQN interpreter
      croc              # transfer files
      cryptsetup        # manage encrypted volumes
      curl              # download files
      docker-compose    # manage multi-container Docker applications
      entr              # run arbitrary commands when files change
      fd                # find files
      ffmpeg-full       # multimedia framework
      file              # determine file type
      ghostscript       # manipulate PDF files
      go-jira           # interact with Jira
      htmlq             # extract data from HTML
      imagemagick       # manipulate images
      killall           # kill processes by name
      libinput          # input device management
      lightburn         # laser cutter software
      mdcat             # render markdown
      netpbm            # image processing tools
      ngrep             # network packet analyzer
      ngrok             # expose local servers to the internet
      nix-direnv-flakes # Nix flakes support
      nix-prefetch-git  # fetch Git repositories
      openssl           # cryptographic library
      openvpn           # VPN client
      orca-c            # midi sequencer
      pandoc            # document converter
      qmk               # keyboard firmware
      rclone            # cloud storage
      ripgrep           # search tool
      rlwrap            # readline wrapper
      rnix-lsp          # Nix language server
      rpi-imager        # Raspberry Pi OS image writer
      rsync             # file synchronization
      sox               # audio processing
      sshfs             # mount remote filesystems
      tmate             # terminal sharing
      unrar             # extract RAR archives
      unzip             # extract ZIP archives
      usbutils          # USB device management
      uucp              # Unix-to-Unix copy
      vagrant           # virtual machine manager
      wget              # download files
      wrk2              # HTTP benchmarking tool
      yq                # YAML processor
    ];
  };
}
