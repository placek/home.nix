{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  ################################# HARDWARE ###################################
  boot.extraModulePackages                                                     = [ ];
  boot.initrd.availableKernelModules                                           = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules                                                           = [ "kvm-intel" ];
  boot.loader.efi.canTouchEfiVariables                                         = true;
  boot.loader.systemd-boot.enable                                              = true;
  hardware.bluetooth.enable                                                    = true;
  hardware.cpu.intel.updateMicrocode                                           = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl.driSupport                                                   = true;
  hardware.opengl.driSupport32Bit                                              = true;
  hardware.opengl.enable                                                       = true;
  services.xserver.resolutions                                                 = [ { x = 1920; y = 1080; } ];
  hardware.pulseaudio.enable                                                   = true;
  hardware.pulseaudio.package                                                  = pkgs.pulseaudioFull;
  networking.hostName                                                          = "alpha";
  networking.hosts."127.0.0.1"                                                 = ["localhost" "dev"];
  services.sshd.enable                                                         = true;
  powerManagement.enable                                                       = true;
  powerManagement.cpuFreqGovernor                                              = "performance";
  services.throttled.enable                                                    = true;

  ################################## SYSTEM ####################################
  boot.consoleLogLevel                                                         = 0;
  boot.supportedFilesystems                                                    = [ "ntfs" ];
  boot.tmp.cleanOnBoot                                                         = true;
  console.keyMap                                                               = "pl";
  hardware.keyboard.zsa.enable                                                 = true;
  i18n.defaultLocale                                                           = "pl_PL.UTF-8";
  nixpkgs.config.allowUnfree                                                   = true;
  services.cron.enable                                                         = true;
  services.openssh.extraConfig                                                 = "StreamLocalBindUnlink yes";
  services.printing.drivers                                                    = [ pkgs.foo2zjs pkgs.mfcl8690cdwcupswrapper ];
  services.printing.enable                                                     = true;
  services.udisks2.enable                                                      = true;
  sound.enable                                                                 = true;
  system.stateVersion                                                          = "23.11";
  time.timeZone                                                                = "Europe/Warsaw";
  virtualisation.docker.autoPrune.dates                                        = "daily";
  virtualisation.docker.enable                                                 = true;
  virtualisation.libvirtd.enable                                               = true;
  security.sudo.wheelNeedsPassword                                             = false;

  ################################# SERVICES ###################################
  services.clamav.daemon.enable                                                = true;
  services.clamav.updater.enable                                               = true;
  services.nfs.server.enable                                                   = true;

  ################################### NFS ######################################
  services.nfs.server.exports                                                  = "/var/projects *(rw,sync,no_subtree_check,no_root_squash,nohide,insecure)";

  ################################### USER #####################################
  programs.fish.enable                                                         = true;
  users.users.placek.description                                               = "Paweł Placzyński";
  users.users.placek.extraGroups                                               = [ "dialout" "audio" "disk" "docker" "input" "messagebus" "networkmanager" "plugdev" "systemd-journal" "video" "wheel" "qemu-libvirtd" "libvirtd" "dialout" ];
  users.users.placek.isNormalUser                                              = true;
  users.users.placek.shell                                                     = pkgs.fish;
  users.users.placek.uid                                                       = 1000;
  users.users.placek.openssh.authorizedKeys.keys                               = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrSau4Jlq3xQNiiEMkgETh6bU0/gSlG7ecOFOhzNrcYtcLBQzKNfJrk/59JmXNxXws3u3RBYk1oCe3xnCdeqSTpj4sLJEfXHBuGR4hk2kdk1ve+A0SxL2RKMEGUuA8v0O/0oRykv1EV3oh8HwfYVj0AQzHNxSk1H815gPGNRaq9OTJJgQvUtjNx09dtdY071rNV3D5/ozUqGczdeRbvSlSCHkLZ9mHFGJxd9lbfMV6Bs/XxHrHg+Tc3HDOSmJq7UZeX9i0kvKdyGz9qFdhuIZL4nJWrRjbAMgvMGJJxohtdqgrMv9xuz5UveNVotWBojrMU6n4UcgB1ugUkrDmDL1aBJP6zeRcgk5CtisSMt2eq69LmBEwZDWNHqVQg2Kft32urOH82VfEeZLT+sXD1kWvCFVRcmZtZlENmmkqr0axp9gf4mg1IBkyM7eXjxTg1lDeDw5yFVG/cfbtOUc+twWFJ7nFlC6wVE5prnRW+qI6gpGB4gGZVtzODmIT4OeTXKI2MZPTMn2pwjmx3NM3p8ofZawr3c8TZwCStuWiIvoes3Ps4kt2Z75hoZ+4+LEucUwop0jees0YxrNoFTbwdbfXH0mBCspeSS65CZ96Og2qdE7s1+t3tdZrBWPmgziZIPtvBAmYmzH9JKAX1JgmRirf4tG5sZ2JbA8WDUqSADmadw== cardno:000611879902"
  ];

  ################################# NETWORK ####################################
  boot.kernel.sysctl."net.ipv4.ip_forward"                                     = 1;

  security.acme.defaults.email                                                 = "placzynski.pawel@gmail.com";
  security.acme.acceptTerms                                                    = true;

  networking.domain                                                            = "local";
  networking.nameservers                                                       = [ "127.0.0.1" "8.8.8.8" ];

  networking.firewall.enable                                                   = true;
  networking.firewall.allowPing                                                = true;
  networking.firewall.trustedInterfaces                                        = [ "eno1" ];
  networking.firewall.checkReversePath                                         = false;
  networking.firewall.allowedUDPPorts                                          = [
    111  # rpcbind
    2049 # nfs
  ];
  networking.firewall.allowedTCPPorts                                          = [
    22   # ssh
    80   # http
    111  # rpcbind
    2049 # nfs
    443  # https
    2222 # git
  ];

  networking.nat.enable                                                        = true;
  networking.nat.internalIPs                                                   = [ "192.168.2.0/24" ];
  networking.nat.externalInterface                                             = "enp0s20f0u2";

  networking.interfaces.enp0s20f0u2.useDHCP                                    = true;
  networking.interfaces.eno1.ipv4.addresses                                    = [ { address = "192.168.2.1"; prefixLength = 24; } ];

  services.dnsmasq.enable                                                      = true;
  services.dnsmasq.settings.server                                             = [ "8.8.8.8" "8.8.4.4" ];
  services.dnsmasq.settings.domain                                             = "lan";
  services.dnsmasq.settings.interface                                          = "eno1";
  services.dnsmasq.settings.bind-interfaces                                    = true;
  services.dnsmasq.settings.dhcp-range                                         = "192.168.2.10,192.168.2.254,24h";

  services.nginx.enable                                                        = true;
  services.nginx.recommendedGzipSettings                                       = true;
  services.nginx.recommendedOptimisation                                       = true;
  services.nginx.recommendedProxySettings                                      = true;
  services.nginx.recommendedTlsSettings                                        = true;
  services.nginx.sslCiphers                                                    = "AES256+EECDH:AES256+EDH:!aNULL";

  services.nginx.virtualHosts."placki.cloud".forceSSL                          = true;
  services.nginx.virtualHosts."placki.cloud".enableACME                        = true;
  services.nginx.virtualHosts."placki.cloud".locations."/"                     = { proxyPass = "http://localhost:8080"; };

  ################################### N8N ######################################
  services.nginx.virtualHosts."auto.placki.cloud".forceSSL                     = true;
  services.nginx.virtualHosts."auto.placki.cloud".enableACME                   = true;
  services.nginx.virtualHosts."auto.placki.cloud".locations."/"                = { proxyPass = "http://localhost:5678"; };
}
