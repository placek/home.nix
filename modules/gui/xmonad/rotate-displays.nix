{ config
, pkgs
, ...
}:
pkgs.writeShellScriptBin "rotate-displays" ''
  displays=($(ls ${config.home.homeDirectory}/.screenlayout/*.sh))
  [ ! -f ${config.home.homeDirectory}/.screenlayout/.current ] && echo ${config.home.homeDirectory}/.screenlayout/default.sh > ${config.home.homeDirectory}/.screenlayout/.current
  current=$(cat ${config.home.homeDirectory}/.screenlayout/.current)

  for (( i = 0; i < ''${#displays[@]}; i++ )); do
    if [ 0 == "$i" ]; then
      previous=$((''${#displays[@]} - 1))
    else
      previous=$((i - 1))
    fi
    if [ "''${displays[i]}" == "$current" ]; then
      echo "''${displays[previous]}" > ${config.home.homeDirectory}/.screenlayout/.current
      bash ${config.home.homeDirectory}/.screenlayout/.current
    fi
  done
''
