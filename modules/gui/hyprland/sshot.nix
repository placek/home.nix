{ config, pkgs, ... }:
pkgs.writeShellScriptBin "sshot" ''
  file="${config.downloadsDirectory}/sshot.png"
  case "$1" in
    w*)
      region=$(${pkgs.slurp}/bin/slurp -u)
      ${pkgs.grim}/bin/grim -g "$region" "$file"
      ;;
    s*)
      region=$(${pkgs.slurp}/bin/slurp)
      ${pkgs.grim}/bin/grim -g "$region" "$file"
      ;;
    *)
      exit 0
      ;;
  esac
  ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
''
