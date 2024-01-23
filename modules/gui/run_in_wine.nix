{ config
, pkgs
, name
, path
, exe
}:
let
  wineContext = "wine-${name}";
  prefix = "${config.home.homeDirectory}/Wine/${name}";
in
pkgs.writeShellScriptBin wineContext ''
  rm -f "${config.home.homeDirectory}/.wine"
  ln -s "${prefix}" "${config.home.homeDirectory}/.wine"
  cd "${config.home.homeDirectory}/.wine/drive_c/${path}"
  exec wine "${exe}"
''
