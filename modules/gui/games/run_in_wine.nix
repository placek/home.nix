{ config
, pkgs
, name
, prefix ? name
, path
, exe
}:
pkgs.writeShellScriptBin "wine-${name}" ''
  export WINEPREFIX="${config.home.homeDirectory}/Wine/${prefix}"
  cd "${config.home.homeDirectory}/Wine/${prefix}/drive_c/${path}"
  exec wine ${exe}
''
