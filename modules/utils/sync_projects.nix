{ config
, lib
, pkgs
, ...
}:
let
  syncProjectsName = "sync-projects";
  syncProjects = pkgs.writeShellScriptBin syncProjectsName ''
    export PATH=${pkgs.openssh}/bin:$PATH
    ${pkgs.coreutils}/bin/nice -n 19 ${pkgs.rsync}/bin/rsync --archive --compress --progress ${config.projectsDirectory}/ ${config.home.username}@${config.cloudDomain}:${config.projectsSyncDirectory}/
  '';
in
{
  options = with lib; {
    syncProjectsExec = mkOption {
      type = types.str;
      default = "${syncProjects}/bin/${syncProjectsName}";
      description = "Path to the executable of the projects sync service";
      readOnly = true;
    };

    projectsSyncDirectory = mkOption {
      type = types.str;
      default = "/var/projects";
      description = "The directory on the cloud server where the projects are stored.";
      readOnly = true;
    };
  };

  config.home.packages = [ syncProjects ];
}
