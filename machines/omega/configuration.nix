{ config
, lib
, pkgs
, modulesPath
, ...
}:
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

  fileSystems."/mnt/projects" = {
    device = "placki.cloud:/var/projects";
    fsType = "nfs";
    options = [ "rw" "hard" "timeo=600" "retrans=2" "x-systemd.automount" "noauto" ];
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  ################################### NIX ######################################
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 30d";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    auto-optimise-store = true
    trusted-users = root @wheel
  '';

  ################################# HARDWARE ###################################
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call nvidia_x11 ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  hardware.bluetooth.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
#   hardware.opengl.driSupport = true;
#   hardware.opengl.driSupport32Bit = true;
  hardware.graphics.enable = true;
#   hardware.pulseaudio.enable = true;
#   hardware.pulseaudio.package = pkgs.pulseaudioFull;
  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.enable = true;
  programs.light.enable = true;
  services.throttled.enable = true;
  services.xserver.resolutions = [ { x = 1920; y = 1080; } ];

  ################################## SYSTEM ####################################
  boot.consoleLogLevel = 0;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.tmp.cleanOnBoot = true;
  console.keyMap = "pl";
  hardware.keyboard.zsa.enable = true;
  i18n.defaultLocale = "pl_PL.UTF-8";
  nixpkgs.config.allowUnfree = true;
  programs.slock.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.cron.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";
  services.printing.drivers = [ pkgs.foo2zjs pkgs.mfcl8690cdwcupswrapper ];
  services.printing.enable = true;
  services.udisks2.enable = true;
#   sound.enable = true;
  system.stateVersion = "24.05";
  time.timeZone = "Europe/Warsaw";
  users.extraGroups.vboxusers.members = [ "placek" ];
  virtualisation.docker.autoPrune.dates = "daily";
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;

  ################################# SERVICES ###################################
  services.acpid.enable = true;
  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  services.greenclip.enable = true;
  services.libinput.enable = true;
  services.libinput.mouse.middleEmulation = false;
  services.libinput.touchpad.naturalScrolling = true;
  services.libinput.touchpad.scrollMethod = "twofinger";
  services.libinput.touchpad.tapping = false;
  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.logind.lidSwitch = "ignore";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.mini.enable = true;
  services.xserver.displayManager.lightdm.greeters.mini.user = "placek";
  services.xserver.enable = true;
  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.xkb.layout = "pl";
  services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
  [greeter]
  show-password-label = false
  invalid-password-text = nope!
  show-input-cursor = false
  password-alignment = left
  password-input-width = 24

  [greeter-theme]
  font = "Iosevka"
  font-weight = normal
  error-color = "#d5c4a1"
  password-color = "#d5c4a1"
  background-color = "#32302f"
  background-image = ""
  window-color = "#32302f"
  border-color = "#fe8019"
border-width = 4px
  password-background-color = "#32302f"
  password-border-width = 0px
  '';

  ################################## NVIDIA ####################################
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.prime.allowExternalGpu = false;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.prime.reverseSync.enable = true;
  services.xserver.videoDrivers = [ "nvidia" "displaylink" ];

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
  networking.hostName = "omega";
  networking.hosts."127.0.0.1" = ["localhost" "dev"];
  networking.domain = "local";

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.firewall.allowedTCPPortRanges = [ { from = 3000; to = 3100; } ];

  networking.networkmanager.enable = true;
  networking.wlanInterfaces.wlan0 = { device = "wlp82s0"; mac = "01:01:01:01:01:01"; };
}
