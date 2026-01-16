{ config
, lib
, pkgs
, modulesPath
, ...
}:
let
  domain = "placki.cloud";
  wan_interface = "enp2s0f0";
  lan_interface = "enp2s0f1";
  aux_interface = "enp7s0";
  traefik_docker_network = "traefik-public";
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e83d2b9c-470d-41dd-9f09-6d193b3c9ced";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BBC1-D424";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c76b99d5-5ae2-4e21-924a-077d48dbc096"; }
    ];


  ################################### NIX ######################################
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 30d";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    auto-optimise-store = true
    trusted-users = root @wheel
  '';

  ################################# HARDWARE ###################################
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.keyboard.zsa.enable = true;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  ################################## BOOT ######################################
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "ahci" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
  boot.consoleLogLevel = 0;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.tmp.cleanOnBoot = true;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  ################################## SYSTEM ####################################
  console.keyMap = "pl";
  i18n.defaultLocale = "pl_PL.UTF-8";
  nixpkgs.config.allowUnfree = true;
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Warsaw";

  ################################# SERVICES ###################################
  services.sshd.enable = true;
  services.cron.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";
  services.printing.drivers = [ pkgs.foo2zjs pkgs.mfcl8690cdwcupswrapper ];
  services.printing.enable = true;
  services.udisks2.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda"; # Use default acceleration
  services.ollama.host = "0.0.0.0"; # Listen on all interfaces
  virtualisation.docker.autoPrune.dates = "daily";
  virtualisation.docker.enable = true;

  ################################### GUI ######################################
  boot.plymouth.enable = true;

  services.xserver.enable = true;
  services.xserver.xkb.layout = "pl";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.enable = true;
  environment.sessionVariables = {
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };
  security.chromiumSuidSandbox.enable = true;

  ################################# MULTIMEDIA #################################
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  ################################## NVIDIA ####################################
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  nixpkgs.config.cudaSupport = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.podman.enable = lib.mkForce false;
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit        # provides nvidia-ctk (and, on NixOS, nvidia-cdi-hook)
    libnvidia-container             # library used by the CLI/hook
    (writeShellScriptBin "nvidia-cdi-hook" ''
      exec ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi "$@"
    '')
  ];

  ################################### USERS ####################################
  programs.fish.enable = true;
  users.users.placek.description = "Paweł Placzyński";
  users.users.placek.extraGroups = [ "dialout" "audio" "disk" "docker" "input" "messagebus" "networkmanager" "plugdev" "systemd-journal" "video" "wheel" "qemu-libvirtd" "libvirtd" "dialout" ];
  users.users.placek.isNormalUser = true;
  users.users.placek.shell = pkgs.fish;
  users.users.placek.uid = 1000;
  users.users.placek.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrSau4Jlq3xQNiiEMkgETh6bU0/gSlG7ecOFOhzNrcYtcLBQzKNfJrk/59JmXNxXws3u3RBYk1oCe3xnCdeqSTpj4sLJEfXHBuGR4hk2kdk1ve+A0SxL2RKMEGUuA8v0O/0oRykv1EV3oh8HwfYVj0AQzHNxSk1H815gPGNRaq9OTJJgQvUtjNx09dtdY071rNV3D5/ozUqGczdeRbvSlSCHkLZ9mHFGJxd9lbfMV6Bs/XxHrHg+Tc3HDOSmJq7UZeX9i0kvKdyGz9qFdhuIZL4nJWrRjbAMgvMGJJxohtdqgrMv9xuz5UveNVotWBojrMU6n4UcgB1ugUkrDmDL1aBJP6zeRcgk5CtisSMt2eq69LmBEwZDWNHqVQg2Kft32urOH82VfEeZLT+sXD1kWvCFVRcmZtZlENmmkqr0axp9gf4mg1IBkyM7eXjxTg1lDeDw5yFVG/cfbtOUc+twWFJ7nFlC6wVE5prnRW+qI6gpGB4gGZVtzODmIT4OeTXKI2MZPTMn2pwjmx3NM3p8ofZawr3c8TZwCStuWiIvoes3Ps4kt2Z75hoZ+4+LEucUwop0jees0YxrNoFTbwdbfXH0mBCspeSS65CZ96Og2qdE7s1+t3tdZrBWPmgziZIPtvBAmYmzH9JKAX1JgmRirf4tG5sZ2JbA8WDUqSADmadw== cardno:000611879902"
  ];

  ################################# NETWORK ####################################
  networking.useDHCP = lib.mkDefault true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  security.acme.defaults.email = "placzynski.pawel@gmail.com";
  security.acme.acceptTerms = true;

  networking.hostName = "alpha";
  networking.hosts."127.0.0.1" = ["localhost" "dev"];
  networking.domain = domain;
  networking.nameservers = [ "127.0.0.1" ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.trustedInterfaces = [ lan_interface "docker0" ];
  networking.firewall.interfaces."docker0".allowedTCPPorts = [ 11434 ];
  networking.firewall.interfaces."br-859ab30c4da2".allowedTCPPorts = [ 11434 ];
  networking.firewall.interfaces."br-a34935e25dbb".allowedTCPPorts = [ 11434 ];
  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    2222 # git
  ];

  networking.nat.enable = true;
  networking.nat.internalIPs = [ "192.168.2.0/24" ];
  networking.nat.externalInterface = wan_interface;

  networking.interfaces."${wan_interface}".useDHCP = true;
  networking.interfaces."${lan_interface}".ipv4.addresses = [ { address = "192.168.2.1"; prefixLength = 24; } ];
  networking.interfaces."${aux_interface}".ipv4.addresses = [ { address = "192.168.3.1"; prefixLength = 24; } ];

  services.dnsmasq.enable = true;
  services.dnsmasq.settings.server = [ "127.0.0.1#5353" ];
  services.dnsmasq.settings.domain = "lan";
  services.dnsmasq.settings.interface = lan_interface;
  services.dnsmasq.settings.bind-interfaces = true;
  services.dnsmasq.settings.dhcp-range = "192.168.2.10,192.168.2.254,24h";

#   Use NextDNS parental control via dnscrypt-proxy2
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:5353" ];
      server_names = [ "NextDNS-94c1a5" ];
      static."NextDNS-94c1a5".stamp = "sdns://AgEAAAAAAAAAAAAOZG5zLm5leHRkbnMuaW8HLzk0YzFhNQ";
    };
  };

  ################################# TRAEFIK ####################################
  services.traefik = {
    enable = true;
    group = "docker";
    staticConfigOptions = {
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
        websecure.transport.respondingTimeouts = {
          readTimeout  = "0s";
          writeTimeout = "0s";
          idleTimeout  = "600s";
        };
        traefik.address = ":8080"; # Enable dashboard & API
      };
      api = {
        dashboard = true;
        insecure = false;
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "placzynski.pawel@gmail.com";
        storage = "/srv/proxy/acme.json";
        httpChallenge.entryPoint = "web";
      };
      providers = {
        docker = {
          endpoint = "unix:///run/docker.sock";
          exposedByDefault = false;
          network = traefik_docker_network;
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers."traefik" = {
          rule = "PathPrefix(`/api`) || pathprefix(`/dashboard`)";
          service = "api@internal";
          entryPoints = [ "traefik" ];
          middlewares = [ "dashboard-auth" ];
        };

        middlewares."dashboard-auth".basicAuth.users = [
          "placek:$2y$05$Z4H0cSxB7/eU6uYV0XFUVO64G8fBijFavJx15N.jBYL2W9U6sIkHe"
        ];
      };
    };
  };

  systemd.services.traefik.preStart = ''
    ${pkgs.docker}/bin/docker network inspect ${traefik_docker_network} >/dev/null 2>&1 || \
    ${pkgs.docker}/bin/docker network create ${traefik_docker_network} || true
  '';

  # POSTGRES
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_16.withPackages (ps: with ps; [
      pgsql-http
      pgvector
      age
    ]);

    dataDir = "/var/lib/postgresql/16";
    enableTCPIP = true;

    settings = {
      listen_addresses = lib.mkForce "127.0.0.1";
      shared_preload_libraries = "age";
      password_encryption = "scram-sha-256";
    };

    authentication = pkgs.lib.mkOverride 10 ''
      local   all             all                                     peer
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';

    ensureDatabases = [ "bible" ];
    ensureUsers = [
      { name = "postgrest"; }
      { name = "anon"; }
    ];
  };

  # PGADMIN
  services.pgadmin = {
    enable = true;
    initialEmail = "placzynski.pawel@gmail.com";
    initialPasswordFile = "/srv/data/.pgadmin-pass";
    port = 5050;
  };

  systemd.services.pgadmin.serviceConfig.Environment = [
    "PGADMIN_LISTEN_ADDRESS=127.0.0.1"
    "PGADMIN_LISTEN_PORT=5050"
  ];
}
