{ config
, lib
, pkgs
, ...
}:
{
  config = {
    systemd.user.services.transcribe = {
      Unit = {
        Description = "Transcribe audio files";
        After = [ "network.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/nice -n 19 /home/placek/.nix-profile/bin/transcribe";
        WorkingDirectory = "/home/placek/Cloud/recordings";
        StandardOutput = "journal";
        StandardError = "journal";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    systemd.user.timers.transcribe = {
      Unit = {
        Description = "Trigger transcribe every 5 minutes";
      };

      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
        Unit = "transcribe.service";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
