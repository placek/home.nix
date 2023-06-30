{ pkgs
}:
pkgs.writeShellScriptBin "speak" ''
  #!${pkgs.stdenv.shell}

  OUTPUT=unset
  LANGUAGE="en"

  usage()
  {
    echo "Usage: speak [ -o | --stdout ] [ -l | --lang LANGUAGE ] TEXT"
    exit 2
  }

  PARSED_ARGUMENTS=$(getopt -a -n speak -o ol: --long stdout,lang: -- "$@")
  VALID_ARGUMENTS=$?
  if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
  fi

  eval set -- "$PARSED_ARGUMENTS"
  while :
  do
    case "$1" in
      -o | --stdout)  OUTPUT=1      ; shift   ;;
      -l | --lang)    LANGUAGE="$2" ; shift 2 ;;
      --)             shift; break ;;
      *)              echo "Unexpected option: $1 - this should not happen."
                      usage ;;
    esac
  done
  TEXT="$@"

  if [ "$OUTPUT" == "1" ]; then
    ${pkgs.python39Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT"
  else
    ${pkgs.python39Packages.gtts}/bin/gtts-cli --lang "$LANGUAGE" "$TEXT" | ${pkgs.sox}/bin/play -q -t mp3 -
  fi
''
