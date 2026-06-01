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

  tmuxify = pkgs.writeShellScriptBin "tmuxify" ''
    if [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1 && [[ -t 1 ]]; then
      session_name=$(basename "$PWD")
      if tmux has-session -t "=$session_name" 2>/dev/null; then
        exec tmux attach-session -t "=$session_name"
      else
        tmux new-session -d -s "$session_name" -c "$PWD"
        tmux send-keys -t "$session_name" "editor" Enter
        exec tmux attach-session -t "$session_name"
      fi
    fi
  '';
in
{
  config.home.packages = [
    tmuxify
    speak
  ];
}
