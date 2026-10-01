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
  traefik_proxy_directory = "/srv/proxy";
  user_data_directory = "/srv/data";
  llama_models_directory = "${user_data_directory}/models";
  dev_services = {
  };

  # Pinned nixos-unstable snapshot, shared by every package pulled forward from
  # unstable (immich, ollama-cuda, llama-cpp-cuda). Pinned to a revision rather
  # than tracking the branch head so rebuilds are reproducible and packages cannot
  # silently jump versions between evaluations. To update: take a new revision from
  # https://channels.nixos.org/nixos-unstable/git-revision and refresh the hash with
  # `nix-prefetch-url --unpack <url>`.
  unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c043004d1c6985732bcc1cbc5a9c9aecbbb4e0f0.tar.gz";
    sha256 = "061x1hflyz80rfmzs3vp4kaf29i8qdsw8pasczyyabn7dd7j61pd";
  }) { config.allowUnfree = true; };

  # Bluetooth pairing persisted declaratively (see systemd.services below).
  # NOTE: the ProtoArc info file contains the BLE long-term key (a secret);
  # it lives in this repo and world-readably in the nix store by design.
  bluetooth_adapter = "8C:68:AB:80:5F:F6";
  protoarc_touchpad = "DA:2A:CE:FD:F8:0B";
  protoarc_touchpad_info = pkgs.writeText "protoarc-t1-plus-info" ''
    [General]
    Name=ProtoArc T1 Plus
    Appearance=0x03c1
    AddressType=static
    SupportedTechnologies=LE;
    Trusted=true
    Blocked=false
    CablePairing=false
    WakeAllowed=true
    Services=00001800-0000-1000-8000-00805f9b34fb;00001801-0000-1000-8000-00805f9b34fb;0000180a-0000-1000-8000-00805f9b34fb;0000180f-0000-1000-8000-00805f9b34fb;00001812-0000-1000-8000-00805f9b34fb;

    [PeripheralLongTermKey]
    Key=BEE4256F797B6991A531B1E52B55AEB1
    Authenticated=2
    EncSize=16
    EDiv=0
    Rand=0

    [SlaveLongTermKey]
    Key=BEE4256F797B6991A531B1E52B55AEB1
    Authenticated=2
    EncSize=16
    EDiv=0
    Rand=0

    [DeviceID]
    Source=2
    Vendor=1256
    Product=28705
    Version=293

    [ConnectionParameters]
    MinInterval=6
    MaxInterval=6
    Latency=66
    Timeout=300
  '';
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

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
  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 30d";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    auto-optimise-store = true
    trusted-users = root @wheel
    download-buffer-size = 524288000
  '';

  ################################# HARDWARE ###################################
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.keyboard.zsa.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Keep the ProtoArc T1 Plus touchpad always trusted and paired by writing its
  # BlueZ pairing record before bluetoothd starts, so it survives even a wiped
  # /var or fresh install. Runs on every boot to enforce the declarative state.
  systemd.services.protoarc-touchpad-pairing = {
    description = "Install declarative Bluetooth pairing for ProtoArc T1 Plus";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      dir="/var/lib/bluetooth/${bluetooth_adapter}/${protoarc_touchpad}"
      mkdir -p "$dir"
      install -m 0600 -o root -g root ${protoarc_touchpad_info} "$dir/info"
    '';
  };
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  ################################## BOOT ######################################
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelModules = [ "kvm-amd" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    # EDID reading fails on the RTX 5080 DP outputs (driver falls back to a
    # synthesized EDID exposing only 640x480). Force a 1920x1080 EDID on both
    # connected DisplayPorts. The blob is provided by pkgs.edid-generator via
    # hardware.firmware below (the kernel's own built-in EDIDs were removed in
    # Linux 6.x, so drm.edid_firmware needs a real firmware file).
    "drm.edid_firmware=DP-1:edid/1920x1080.bin,DP-2:edid/1920x1080.bin"
  ];
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "ahci" "sd_mod" "sdhci_pci" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
  boot.consoleLogLevel = 0;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.tmp.cleanOnBoot = true;

  ################################## SYSTEM ####################################
  console.keyMap = "pl";
  i18n.defaultLocale = "pl_PL.UTF-8";
  nixpkgs.config.allowUnfree = true;
  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/Warsaw";

  ################################# SERVICES ###################################
  services.sshd.enable = true;
  services.cron.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";
  services.printing.enable = true;
  services.udisks2.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
#   services.ollama.enable = true;
#   services.ollama.package = unstable.ollama-cuda;
#   services.ollama.acceleration = "cuda"; # Use default acceleration
#   services.ollama.host = "0.0.0.0"; # Listen on all interfaces
  virtualisation.docker.autoPrune.dates = "daily";
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;

  ################################### GUI ######################################
  boot.plymouth.enable = true;

  services.xserver.enable = true;
  services.xserver.xkb.layout = "pl";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.enable = true;
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  security.chromiumSuidSandbox.enable = true;

  ################################# MULTIMEDIA #################################
  services.pipewire.enable = true;
  services.pipewire.audio.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;

  ######################### POWERMANAGEMENT DISABLE ############################
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  ################################## NVIDIA ####################################
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  # Provides edid/1920x1080.bin for the drm.edid_firmware override above.
  hardware.firmware = [ pkgs.edid-generator ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = false;
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = false;
  virtualisation.podman.enable = lib.mkForce false;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;

  ################################### USERS ####################################
  programs.fish.enable = true;
  users.users.placek.description = "Paweł Placzyński";
  users.users.placek.extraGroups = [ "dialout" "audio" "disk" "docker" "input" "messagebus" "networkmanager" "plugdev" "systemd-journal" "video" "wheel" "qemu-libvirtd" "libvirtd" "dialout" ];
  users.users.placek.isNormalUser = true;
  users.users.placek.shell = pkgs.bashInteractive;
  users.users.placek.uid = 1000;
  users.users.placek.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrSau4Jlq3xQNiiEMkgETh6bU0/gSlG7ecOFOhzNrcYtcLBQzKNfJrk/59JmXNxXws3u3RBYk1oCe3xnCdeqSTpj4sLJEfXHBuGR4hk2kdk1ve+A0SxL2RKMEGUuA8v0O/0oRykv1EV3oh8HwfYVj0AQzHNxSk1H815gPGNRaq9OTJJgQvUtjNx09dtdY071rNV3D5/ozUqGczdeRbvSlSCHkLZ9mHFGJxd9lbfMV6Bs/XxHrHg+Tc3HDOSmJq7UZeX9i0kvKdyGz9qFdhuIZL4nJWrRjbAMgvMGJJxohtdqgrMv9xuz5UveNVotWBojrMU6n4UcgB1ugUkrDmDL1aBJP6zeRcgk5CtisSMt2eq69LmBEwZDWNHqVQg2Kft32urOH82VfEeZLT+sXD1kWvCFVRcmZtZlENmmkqr0axp9gf4mg1IBkyM7eXjxTg1lDeDw5yFVG/cfbtOUc+twWFJ7nFlC6wVE5prnRW+qI6gpGB4gGZVtzODmIT4OeTXKI2MZPTMn2pwjmx3NM3p8ofZawr3c8TZwCStuWiIvoes3Ps4kt2Z75hoZ+4+LEucUwop0jees0YxrNoFTbwdbfXH0mBCspeSS65CZ96Og2qdE7s1+t3tdZrBWPmgziZIPtvBAmYmzH9JKAX1JgmRirf4tG5sZ2JbA8WDUqSADmadw== cardno:000611879902"
  ];

  ################################## FILES #####################################
  systemd.tmpfiles.rules = [
    "d ${user_data_directory} 0755 placek users -"
    "d ${traefik_proxy_directory} 0755 traefik docker -"
    "f ${traefik_proxy_directory}/acme.json 0600 traefik docker -"
    "d ${user_data_directory}/projects 0700 placek users -"
    "d ${user_data_directory}/immich 0750 immich immich -"
    "d ${user_data_directory}/minecraft 0750 minecraft minecraft -"
    "d ${user_data_directory}/brain 0700 placek users -"
    "d ${llama_models_directory} 0755 placek users -"
    "L /home/placek/Brain - - - - ${user_data_directory}/brain"
    "L /home/placek/Projects - - - - ${user_data_directory}/projects"
    "L /home/placek/Media - - - - /run/media/placek"
  ];

  ################################# NETWORK ####################################
  networking.useDHCP = lib.mkDefault true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  security.acme.defaults.email = "placzynski.pawel@gmail.com";
  security.acme.acceptTerms = true;

  networking.hostName = "alpha";
  networking.hosts."127.0.0.1" = ["localhost" "dev"] ++ (lib.mapAttrsToList (name: _: "${name}.dev") dev_services);
  networking.domain = domain;
  networking.nameservers = [ "127.0.0.1" ];

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.trustedInterfaces = [ lan_interface aux_interface "docker0" ];
  networking.firewall.interfaces."docker0".allowedTCPPorts = [ 11434 ];
  networking.firewall.interfaces."br-859ab30c4da2".allowedTCPPorts = [ 11434 ];
  networking.firewall.interfaces."br-a34935e25dbb".allowedTCPPorts = [ 11434 ];
  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    2222 # git
    25565 # minecraft
  ];

  networking.nat.enable = true;
  networking.nat.internalIPs = [
    "192.168.2.0/24"
    "192.168.3.0/24"
  ];
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

  # bind-interfaces requires the LAN address to already be assigned at start.
  systemd.services.dnsmasq = {
    after = [ "network-addresses-${lan_interface}.service" ];
    wants = [ "network-addresses-${lan_interface}.service" ];
  };

  # Use NextDNS parental control via dnscrypt-proxy2
  services.dnscrypt-proxy.enable = true;
  services.dnscrypt-proxy.settings.listen_addresses = [ "127.0.0.1:5353" ];
  services.dnscrypt-proxy.settings.server_names = [ "NextDNS-94c1a5" ];
  services.dnscrypt-proxy.settings.static."NextDNS-94c1a5".stamp = "sdns://AgEAAAAAAAAAAAAOZG5zLm5leHRkbnMuaW8HLzk0YzFhNQ";

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
        storage = "${traefik_proxy_directory}/acme.json";
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
        routers = (lib.mapAttrs' (name: port: lib.nameValuePair name {
          rule = "Host(`${name}.dev`)";
          service = name;
          entryPoints = [ "web" ];
        }) dev_services) // {
          "traefik" = {
            rule = "PathPrefix(`/api`) || PathPrefix(`/dashboard`)";
            service = "api@internal";
            entryPoints = [ "traefik" ];
            middlewares = [ "dashboard-auth" ];
          };
          "bible-api" = {
            rule = "Host(`api.bible.${domain}`)";
            service = "bible-api";
            entryPoints = [ "websecure" ];
            tls.certResolver = "letsencrypt";
          };
          "immich" = {
            rule = "Host(`immich.${domain}`)";
            service = "immich";
            entryPoints = [ "websecure" ];
            tls.certResolver = "letsencrypt";
          };
          "psalmy" = {
            rule = "Host(`psalmy.${domain}`)";
            service = "psalmy";
            entryPoints = [ "websecure" ];
            tls.certResolver = "letsencrypt";
          };
        };

        services = (lib.mapAttrs' (name: port: lib.nameValuePair name {
          loadBalancer.servers = [ { url = "http://127.0.0.1:${toString port}"; } ];
        }) dev_services) // {
          "bible-api".loadBalancer.servers = [
            { url = "http://${toString config.services.postgrest.settings.server-host}:${toString config.services.postgrest.settings.server-port}"; }
          ];
          "immich".loadBalancer.servers = [
            { url = "http://${toString config.services.immich.host}:${toString config.services.immich.port}"; }
          ];
          "psalmy".loadBalancer.servers = [
            { url = "http://127.0.0.1:8081"; }
          ];
        };

        middlewares."dashboard-auth".basicAuth.users = [
          "placek:$2y$05$Z4H0cSxB7/eU6uYV0XFUVO64G8fBijFavJx15N.jBYL2W9U6sIkHe"
        ];
      };
    };
  };

  systemd.services.traefik.preStart = ''
    ${pkgs.docker_29}/bin/docker network inspect ${traefik_docker_network} >/dev/null 2>&1 || \
    ${pkgs.docker_29}/bin/docker network create ${traefik_docker_network} || true
  '';

  # POSTGRES
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_17.withPackages (ps: with ps; [
      pgsql-http
      pgvector
    ]);

    dataDir = "/var/lib/postgresql/17";
    enableTCPIP = true;

    ensureDatabases = [ "bible" ];

    ensureUsers = [
      { name = "postgrest"; }
      { name = "web_anon"; ensureClauses.login = false; }
    ];

    settings = {
      listen_addresses = lib.mkForce "127.0.0.1";
      password_encryption = "scram-sha-256";
    };

    authentication = pkgs.lib.mkOverride 10 ''
      local   all             all                                     peer
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';
  };

  #### IMMICH ########################################################################
  # Immich photo management service with security updates.
  # - Uses unstable.immich (3.x) to fix CVE-2026-59258, CVE-2026-82272 in 2.7.5
  # - Pinned nixos-unstable hash is defined in the let-block above (line 25-28)
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = "${user_data_directory}/immich";
    package = unstable.immich;
#     database.enableVectors = false;
  };

  #### POSTGREST (systemd service) ####
  services.postgrest = {
    enable = true;

    settings = {
      server-host = "127.0.0.1";
      server-port = 3000;
      server-unix-socket = null;

      db-uri.dbname = "bible";
      db-uri.host = "/run/postgresql";
      db-uri.user = "postgrest";
      db-schema = "api";
      db-anon-role = "web_anon";
      openapi-mode = "follow-privileges";
    };
  };

  systemd.services.postgresql-setup.script = lib.mkAfter ''
    psql -tAc 'GRANT "web_anon" TO "postgrest"'
  '';

  ################################# HERMES #####################################
  # Zależności systemowe pod hermesa
  environment.systemPackages = with pkgs; [
    uv
    python313
    nodejs_22       # potrzebny do browser tools / serwerów MCP po npx
    git
    ripgrep
    ffmpeg
    gcc             # przy budowaniu sporadycznych wheeli z C-extensions
  ];

  # Dla wheeli z natywnymi binariami linkowanymi do FHS-owego ld-linux
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    libffi
    glib
  ];

  ################################ MINECRAFT ###################################
  # Vanilla Java Edition server, reachable from the internet at
  # minecraft.placki.cloud. Deliberately NOT behind Traefik: the Minecraft
  # protocol is raw TCP with no TLS and therefore no SNI, so a reverse proxy has
  # no hostname to route on. The hostname resolves at the DNS layer instead -
  # *.placki.cloud is a wildcard A record at home.pl pointing here - and the
  # port is opened directly in allowedTCPPorts above. Keeping the default 25565
  # is what lets clients type a bare "minecraft.placki.cloud" with no :port and
  # no _minecraft._tcp SRV record.
  services.minecraft-server = {
    enable = true;
    eula = true;

    # Required for `whitelist` and `serverProperties` below to have ANY effect;
    # without it the module just runs the jar against whatever is already in
    # dataDir. The trade-off: whitelist.json and server.properties are
    # regenerated from this file on every start, so in-game `/whitelist add` and
    # hand-edits to server.properties are silently reverted on the next
    # restart. Adding a player is a config edit + `make switch`.
    declarative = true;

    # Under ${user_data_directory} rather than the module default of
    # /var/lib/minecraft, matching immich - keeps every piece of user data worth
    # backing up (the world lives here) under one tree.
    dataDir = "${user_data_directory}/minecraft";

    # The module would happily open the port itself, but this config keeps all
    # public ports in the single allowedTCPPorts list above so the exposed
    # surface is readable in one place.
    openFirewall = false;

    # Xms == Xmx on purpose: a fixed heap avoids the GC churn and pause spikes
    # that come from the JVM resizing the heap under load. 4G is ample for
    # vanilla with a handful of players and is deliberately modest on a 123 GiB
    # box, because llama-cpp keeps ~96 GB of model weights mmap'd - those pages
    # are reclaimable under pressure, a committed JVM heap is not, so there is
    # no reason to take more than the server can use. The G1 flags are the
    # standard Aikar tuning: collect earlier and more incrementally to keep
    # pauses off the 50 ms tick.
    jvmOpts = lib.concatStringsSep " " [
      "-Xms4G"
      "-Xmx4G"
      "-XX:+UseG1GC"
      # MUST precede G1NewSizePercent / G1MaxNewSizePercent below: HotSpot
      # parses argv in order and refuses an experimental flag it has not been
      # unlocked for yet ("The unlock option must precede 'G1NewSizePercent'"),
      # which aborts JVM startup outright. This is also why jvmOpts is a list
      # rather than an attrset - an attrset would be emitted in Nix's
      # alphabetical order and put the unlock after the flags it unlocks.
      "-XX:+UnlockExperimentalVMOptions"
      "-XX:+ParallelRefProcEnabled"
      "-XX:MaxGCPauseMillis=200"
      "-XX:+DisableExplicitGC"
      "-XX:G1NewSizePercent=30"
      "-XX:G1MaxNewSizePercent=40"
      "-XX:G1HeapRegionSize=8M"
      "-XX:G1ReservePercent=20"
      "-XX:InitiatingHeapOccupancyPercent=15"
    ];

    # Minecraft usernames -> account UUIDs. The module's type is a strMatching
    # on the UUID format, so a bare username fails at evaluation time, not at
    # runtime. Resolve a name with:
    #   curl -s https://api.mojang.com/users/profiles/minecraft/<name>
    # and hyphenate the 32-char id as 8-4-4-4-12.
    #
    # An empty set here combined with white-list = true below means NOBODY can
    # join - which is the safe state to leave this in, not a broken one.
    whitelist = {
    };

    serverProperties = {
      server-port = 25565;
      motd = "placki.cloud";

      # The pair matters. white-list gates new logins; enforce-whitelist also
      # kicks a player who is already online when they are removed from the
      # list (and on every reload of it). Without the second, dropping someone
      # only takes effect the next time they reconnect.
      white-list = true;
      enforce-whitelist = true;

      # Mojang session-server authentication. Never turn this off on a
      # publicly-reachable server: offline-mode lets anyone connect claiming any
      # username, which also defeats the whitelist above since it matches on
      # exactly that name.
      online-mode = true;

      max-players = 20;
      difficulty = "normal";
      gamemode = "survival";
      view-distance = 12;
      simulation-distance = 10;

      # No remote console and no query protocol: both are extra listeners on a
      # box whose 25565 is exposed to the internet, and neither is needed. The
      # module already wires stdin to a FIFO at /run/minecraft-server.stdin, so
      # console commands go through:
      #   echo "say hello" | sudo tee /run/minecraft-server.stdin
      enable-rcon = false;
      enable-query = false;

      # Command blocks execute arbitrary server commands from inside the world;
      # off by default and left off.
      enable-command-block = false;
    };
  };
}
