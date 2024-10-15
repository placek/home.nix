{ config
, lib
, pkgs
, ...
}:
let
  rsync = "${pkgs.rsync}/bin/rsync";
  source = "${config.projectsDirectory}/";
  target = "${config.home.username}@${config.cloudDomain}:${config.projectsSyncDirectory}/";
  rsyncCommand = "${rsync} --archive --compress --progress ${source} ${target}";
in
{
  options = with lib; {
    projectsSyncDirectory = mkOption {
      type = types.str;
      default = "/var/projects";
      description = "The directory on the cloud server where the projects are stored.";
      readOnly = true;
    };
  };

  config = {
    systemd.user.services.projectsSyncService = {
      Service = {
        ExecStart = "${pkgs.coreutils}/bin/nice -n 19 ${rsyncCommand}";
        Restart = "on-failure";
        TimeoutStartSec = "10min";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    systemd.user.timers.projectsSyncTimer = {
      Timer = {
        OnCalendar = "hourly";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
