{ config
, pkgs
, ...
}:
pkgs.writeShellScriptBin "sshot" ''
  #!${pkgs.stdenv.shell}

  file="${config.browser.downloadsDirectory}/sshot.png"

  case "$1" in
    w*)
      shift
      ${pkgs.scrot}/bin/scrot -q 100 -u "$file"
      ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$file"
      ;;
    s*)
      shift
      ${pkgs.scrot}/bin/scrot -q 100 -s "$file"
      ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$file"
      ;;
    *)
      ;;
  esac
''
