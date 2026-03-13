{ config
, lib
, pkgs
, ...
}:
let
  dcc6502 = import ./dcc6502.nix { inherit pkgs; };
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
      default = "${pkgs.aria2}/bin/aria2c";
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
      # 6502 toolchain
      cc65               # 6502 compiler
      dcc6502            # 6502 disassembler
      minipro            # EEPROM programmer
      picocom            # serial terminal

      # arduino and related tools
      arduino            # electronics prototyping platform
      avrdude            # program AVR microcontrollers
      pkgsCross.avr.buildPackages.gcc

      # networking and remote management
      bind               # DNS server
      croc               # transfer files
      curl               # request URLs
      ngrep              # network packet analyzer
      ngrok              # expose local servers to the internet
      openvpn            # VPN client
      rclone             # cloud storage
      rsync              # file synchronization
      uucp               # Unix-to-Unix copy
      wget               # download files
      wrk2               # HTTP benchmarking tool
      xh                 # HTTP client

      # filesystem and file management
      cryptsetup         # manage encrypted volumes
      fd                 # find files
      file               # determine file type
      nfs-utils          # NFS client
      ripgrep            # search tool
      sshfs              # mount remote filesystems

      # file processing and manipulation
      ghostscript        # manipulate PDF files
      htmlq              # extract data from HTML
      imagemagick        # manipulate images
      jq                 # JSON processor
      mdcat              # render markdown
      netpbm             # image processing tools
      pandoc             # document converter
      pdftk              # manipulate PDF files
      typst              # typesetting system
      yq                 # YAML processor

      # utilities and command-line tools
      bash               # auxilary shell
      docker-compose     # manage multi-container Docker applications
      entr               # run arbitrary commands when files change
      killall            # kill processes by name
      libinput           # input device management
      nix-direnv         # Nix flakes support
      nix-prefetch-git   # fetch Git repositories
      openssl            # cryptographic library
      qmk                # keyboard firmware
      rlwrap             # readline wrapper
      usbutils           # USB device management

      # multimedia and entertainment
      ffmpeg-full        # multimedia framework
      orca-c             # midi sequencer
      playerctl          # control media players
      sox                # audio processing

      # archive extraction tools
      p7zip              # extract 7z archives
      unrar              # extract RAR archives
      unzip              # extract ZIP archives

      # AI tools
      codex              # OpenAI Codex CLI
      whisper-cpp-vulkan # speech to text
    ];
  };
}
