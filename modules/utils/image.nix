{ pkgs
}:
pkgs.writeShellScriptBin "image" ''
  case "$1" in
    stack*) # combine images horizontally
      convert +append "$1" "$2" "''${1%.*}_''${2%.*}_merged.png"
      ;;

    stackv*) # combine images vertically
      convert -append "$1" "$2" "''${1%.*}_''${2%.*}_merged.png"
      ;;

    resize*) # resize image
      convert "$2" -resize "$1" "''${2%.*}_resized.png"
      ;;

    alpha*) # add alpha channel basing on color
      convert "$2" -fuzz 10% -transparent "$1" "''${2%.*}_alpha.png"
      ;;

    grays*) # convert to grayscale
      convert "$1" -type Grayscale a_"''${1%.*}_grayscale.png"
      ;;

    *)
      ;;

    *)
      >&2 echo "usage: $0 info filename"
      >&2 echo "       $0 asubtitles filename1 filename2"
      >&2 echo "       $0 awatermark filename1 filename2"
      >&2 echo "       $0 gif filename"
      >&2 echo "       $0 crop x y w h filename"
      >&2 echo "       $0 merge filename1 filename2"
      >&2 echo "       $0 resize w h filename"
      >&2 echo "       $0 rotate filename"
      >&2 echo "       $0 screen-capture filename"
      >&2 echo "       $0 stabilize filename"
      >&2 echo "       $0 trim from to filename"
      exit 0
      ;;
  esac
''
