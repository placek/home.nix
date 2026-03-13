{ config
, lib
, pkgs
, ...
}:
let
  speak = pkgs.writeShellScriptBin "speak" ''
    OUTPUT=unset
    LANGUAGE="''${LANGUAGE:-pl}"

    usage()
    {
      echo "Usage: speak [ -o | --stdout ] [ -l | --lang LANGUAGE ] TEXT"
      exit 2
    }

    PARSED_ARGUMENTS=$(getopt -a -n speak -o o --long stdout -- "$@")
    VALID_ARGUMENTS=$?
    if [ "$VALID_ARGUMENTS" != "0" ]; then
      usage
    fi

    eval set -- "$PARSED_ARGUMENTS"
    while :
    do
      case "$1" in
        -o | --stdout)  OUTPUT=1      ; shift   ;;
        --)             shift; break ;;
        *)              echo "Unexpected option: $1 - this should not happen."
                        usage ;;
      esac
    done
    TEXT="$@"

    if [ "$OUTPUT" == "1" ]; then
      ${pkgs.python312Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT"
    else
      ${pkgs.python312Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT" | ${pkgs.sox}/bin/play -q -t mp3 -
    fi
  '';

  psalmus = pkgs.writeShellScriptBin "psalmus" ''
    if [ $# -eq 0 ]; then
      today=$(date +"%Y-%m-%d")
    else
      today=$(date -d "$1" +"%Y-%m-%d" 2>/dev/null)
      if [ $? -ne 0 ]; then
        echo "invalid date format"
        exit 1
      fi
    fi

    day_no=$(date -d "$today" +"%-j")
    psalm_no=$(( (day_no * 79) % 150 + 1 ))

    echo "$psalm_no"
  '';
in
{
  config.home.packages = [
    psalmus
    speak
  ];
}
