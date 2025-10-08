{ config
, lib
, pkgs
, ...
}:
let
  dcc6502 = import ./dcc6502.nix { inherit pkgs; };
  minipro = import ./minipro.nix { inherit pkgs; };
in
{
  options = with lib; {
    projectsDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Projects";
      description = "A path to project directory.";
    };

    downloadsDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Downloads";
      description = "A path to downloads directory.";
    };

    documentsDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Documents";
      description = "A path to documents directory.";
    };

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

    cloudDomain = mkOption {
      type = types.str;
      default = "placki.cloud";
      description = "The domain of the cloud server.";
      readOnly = true;
    };
  };

  imports = [
    ./tertius.nix
    ./nnn.nix
    ./scripts.nix
  ];

  config = {
    programs.aria2.enable = true;
    programs.bat.config.theme = "gruvbox-dark";
    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.btop.settings.theme = "gruvbox";
    programs.btop.settings.theme_background = false;
    programs.direnv.enable = true;
    programs.fzf.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.nix-index.enable = true;
    programs.nix-your-shell.enable = true;
    programs.yt-dlp.enable = true;

    services.tldr-update.enable = true;

    home.packages = with pkgs; [
      dcc6502           # 6502 disassembler
      minipro           # EEPROM programmer
      codex             # OpenAI Codex CLI
      pkgsCross.avr.buildPackages.gcc

      ansible           # manage remote machines
      arduino           # electronics prototyping platform
      avrdude           # program AVR microcontrollers
      bash              # shell
      bind              # DNS server
      cbqn              # BQN interpreter
      cc65              # 6502 compiler
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
      immich-cli        # Immich command line client
      immich-go         # Immich command line client google
      killall           # kill processes by name
      libinput          # input device management
      lightburn         # laser cutter software
      mdcat             # render markdown
      netpbm            # image processing tools
      nfs-utils         # NFS client
      ngrep             # network packet analyzer
      ngrok             # expose local servers to the internet
      nix-direnv-flakes # Nix flakes support
      nix-prefetch-git  # fetch Git repositories
      nvidia-container-toolkit
      nvidia-docker     # Docker integration for NVIDIA GPUs
      openssl           # cryptographic library
      openvpn           # VPN client
      orca-c            # midi sequencer
      p7zip             # extract 7z archives
      pandoc            # document converter
      pdftk             # manipulate PDF files
      playerctl         # control media players
      qFlipper          # flipper control software
      qmk               # keyboard firmware
      rclone            # cloud storage
      ripgrep           # search tool
      rlwrap            # readline wrapper
      rpi-imager        # Raspberry Pi OS image writer
      rsync             # file synchronization
      sox               # audio processing
      sshfs             # mount remote filesystems
      tldr              # community-driven command-line help
      tmate             # terminal sharing
      typst             # typesetting system
      unrar             # extract RAR archives
      unzip             # extract ZIP archives
      usbutils          # USB device management
      uucp              # Unix-to-Unix copy
      wget              # download files
      whisper-cpp       # speech to text
      wrk2              # HTTP benchmarking tool
      xh                # HTTP client
      yq                # YAML processor
    ];
  };
}
