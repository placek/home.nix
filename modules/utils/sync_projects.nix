{ config
, lib
, pkgs
, ...
}:
let
  placki = pkgs.writeShellScriptBin "placki" ''
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'

    subcommand="$1"
    shift || true

    projects_dir="${config.projectsDirectory}"
    server_host="${config.cloudDomain}"
    server_user="${config.home.username}"
    remote_projects_dir="${config.projectsSyncDirectory}"
    run_dir="/srv/run"
    etc_dir="/srv/etc"

    current_dir="$(pwd)"
    if [[ "$current_dir" != "$projects_dir"* ]]; then
      >&2 echo -e "''${RED}E>''${RESET} you are outside of the projects directory"
      exit 1
    fi

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      >&2 echo -e "''${RED}E>''${RESET} you are not inside a Git repository"
      exit 1
    fi

    git_root="$(git rev-parse --show-toplevel)"
    project_name="''${git_root#"$projects_dir/"}"

    case "$subcommand" in
      deploy)
        revision="$(git -C "$git_root" rev-parse HEAD)"
        echo -e "''${BLUE}>>''${RESET} syncing project to server"
        ${pkgs.coreutils}/bin/nice -n 19 ${pkgs.rsync}/bin/rsync --archive --compress --progress "$git_root/" "$server_user@$server_host:$remote_projects_dir/$project_name/"

        echo -e "''${BLUE}>>''${RESET} deploying ''${BOLD}$project_name''${RESET} @ ''${YELLOW}$revision''${RESET}"
        ssh "$server_user@$server_host" bash <<EOF
set -e
mkdir -p "$run_dir/$project_name"
cd "$run_dir/$project_name"

if [ ! -d .git ]; then
  git clone "$remote_projects_dir/$project_name" .
fi

echo -e "\033[0;34m>>\033[0m storing current revision for rollback (if any)..."
if git rev-parse HEAD > /dev/null 2>&1; then
  git rev-parse HEAD > .last-rev || true
fi

git fetch
git checkout "$revision"

docker compose -f docker-compose.placki.yaml build --pull
docker compose -f docker-compose.placki.yaml up -d
EOF
        ;;

      rollback)
        echo -e "''${BLUE}>>''${RESET} rolling back ''${BOLD}$project_name''${RESET} on ''${YELLOW}$server_host''${RESET}..."
        ssh "$server_user@$server_host" bash <<EOF
set -e
cd "$run_dir/$project_name"

if [ ! -f .last-rev ]; then
  echo -e "\033[0;31mE>\033[0m no .last-rev found, cannot rollback"
  exit 1
fi

last_rev="$(cat .last-rev)"
echo -e "\033[0;34m>>\033[0m rolling back to revision \033[1;33m$last_rev\033[0m"

git checkout "$last_rev"
docker compose -f docker-compose.placki.yaml build --pull
docker compose -f docker-compose.placki.yaml up -d
EOF
        ;;

      sync)
        echo -e "''${BLUE}>>''${RESET} syncing project ''${BOLD}$project_name''${RESET}..."
        ${pkgs.coreutils}/bin/nice -n 19 ${pkgs.rsync}/bin/rsync --archive --compress --progress "$git_root/" "$server_user@$server_host:$remote_projects_dir/$project_name/"
        ;;

      sync-all)
        source_dir="${config.projectsDirectory}"
        dest="${config.home.username}@${config.cloudDomain}:${config.projectsSyncDirectory}"
        echo -e "''${BLUE}>>''${RESET} syncing all projects..."
        ${pkgs.coreutils}/bin/nice -n 19 ${pkgs.rsync}/bin/rsync --archive --compress --progress "$source_dir/" "$dest/"
        ;;

      etc)
        echo -e "''${BLUE}>>''${RESET} connecting to ''${BOLD}$etc_dir/$project_name''${RESET} on ''${YELLOW}$server_host''${RESET}..."
        ssh "$server_user@$server_host" -t "mkdir -p $etc_dir/$project_name && cd $etc_dir/$project_name && exec \$SHELL"
        ;;

      *)
        echo -e "''${RED}E>''${RESET} unknown subcommand: ''${YELLOW}$subcommand''${RESET}"
        echo "Usage: placki [deploy|rollback|sync|sync-all|etc]"
        exit 1
        ;;
    esac
  '';
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

  config.home.packages = [ placki ];
}
