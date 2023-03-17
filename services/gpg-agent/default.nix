let
  settings = import ../../settings;
in
{
  enable = true;
  enableSshSupport = true;
  enableFishIntegration = true;
  pinentryFlavor = "gnome3";
  enableScDaemon = true;
  defaultCacheTtl = 1800;
  defaultCacheTtlSsh = 1800;
  sshKeys = [ settings.key.ssh ];
}
