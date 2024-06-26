{ pkgs
}:
pkgs.writeShellScriptBin "audio" ''
  case "$1" in
    dev*) # list devices
      pactl list sources short
      ;;

    loop*) # redirect audio input to other card output
      parec -d $2 --latency-msec 1 | pacat -p --latency-msec 1
      ;;

    *)
      >&2 echo "usage: $0 devices"
      >&2 echo "       $0 loop <device>"
      exit 0
      ;;
  esac
''
