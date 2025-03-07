{ config
, lib
, pkgs
, ...
}:
let
  speak = pkgs.writeShellScriptBin "speak" ''
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
  '';

  image = pkgs.writeShellScriptBin "image" ''
    case "$1" in
      stack*) # combine images horizontally
        ${pkgs.imagemagick}/bin/convert +append "$1" "$2" "''${1%.*}_''${2%.*}_merged.png"
        ;;

      stackv*) # combine images vertically
        ${pkgs.imagemagick}/bin/convert -append "$1" "$2" "''${1%.*}_''${2%.*}_merged.png"
        ;;

      resize*) # resize image
        ${pkgs.imagemagick}/bin/convert "$2" -resize "$1" "''${2%.*}_resized.png"
        ;;

      alpha*) # add alpha channel basing on color
        ${pkgs.imagemagick}/bin/convert "$2" -fuzz 10% -transparent "$1" "''${2%.*}_alpha.png"
        ;;

      grays*) # convert to grayscale
        ${pkgs.imagemagick}/bin/convert "$1" -type Grayscale a_"''${1%.*}_grayscale.png"
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
  '';

  video = pkgs.writeShellScriptBin "video" ''
    trap 'rm -f "transforms.trf"' EXIT

    case "$1" in
      i*) # info
        ${pkgs.ffmpeg}/bin/ffmpeg -i "$2" && exit 0
        ;;

      as*) # add subtitles
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$3" -i "$2" -codec:v copy -codec:a copy -codec:s mov_text "''${3%.*}_with_subtitles.mp4" && exit 0
        ;;

      aw*) # add watermark
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$3" -i "$2" -filter_complex "overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2" "''${3%.*}_with_watermark.mp4" && exit 0
        ;;

      c*) # crop
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$6" -filter:v "crop=$4:$5:$2:$3" "''${6%.*}_cropped.mp4" && exit 0
        ;;

      m*) # merge (side-by-side)
        second=$(basename -- "$3")
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$2" -i "$3" -filter_complex "[0:v][1:v]hstack,format=yuv420p[v];[0:a][1:a]amerge[a]" -map "[v]" -map "[a]" -codec:v libx264 -crf 18 -ac 2 "''${2%.*}"_"''${second%.*}_merged.mp4" && exit 0
        ;;

      p*) # preview
        ${pkgs.ffmpeg}/bin/ffplay "$2" && exit 0
        ;;

      re*) # resize
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$4" -filter:v "scale=$2:$3" "''${4%.*}_resized.mp4" && exit 0
        ;;

      ro*) # rotate 90 deg clockwise
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$2" -filter:v "transpose=dir=clock" "''${2%.*}_rotated.mp4" && exit 0
        ;;

      sc*) # screen capture with sound
        ${pkgs.ffmpeg}/bin/ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0+0,0 -f pulse -ac 2 -i 1 -acodec aac -strict experimental "$2" && exit 0
        ;;

      st*) # anti-shock
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$2" -filter:v "vidstabdetect=stepsize=32:shakiness=10:accuracy=10:result=transforms.trf" -f null - && ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$2" -filter:v "vidstabtransform=input=transforms.trf:zoom=0:smoothing=10,unsharp=5:5:0.8:3:3:0.4" -codec:v libx264 -tune film -codec:a copy -preset slow "''${2%.*}_no_shock.mp4" && exit 0
        ;;

      t*) # trim
        ${pkgs.ffmpeg}/bin/ffmpeg -loglevel fatal -i "$4" -ss "$2" -t "$3" -codec:v copy -codec:a copy "''${4%.*}_trimmed.mp4" && exit 0
        ;;

      gif)
        ${pkgs.ffmpeg}/bin/ffmpeg -i "$2" -vf "fps=10,scale=320:-1:flags=lanczos" -c:v pam -f image2pipe - | ${pkgs.imagemagick}/bin/convert -delay 10 - -loop 0 -layers optimize "''${2%.*}.gif"
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
  '';

  audio = pkgs.writeShellScriptBin "audio" ''
    case "$1" in
      dev*) # list devices
        ${pkgs.pulseaudio}/bin/pactl list sources short
        ;;

      loop*) # redirect audio input to other card output
        ${pkgs.pulseaudio}/bin/parec -d $2 --latency-msec 1 | ${pkgs.pulseaudio}/bin/pacat -p --latency-msec 1
        ;;

      *)
        >&2 echo "usage: $0 devices"
        >&2 echo "       $0 loop <device>"
        exit 0
        ;;
    esac
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

  transcribe = pkgs.writeShellScriptBin "transcribe" ''
    LANGUAGE="''${LANGUAGE:-pl}"
    MODEL="''${MODEL:-medium}"
    FORMAT="''${FORMAT:-srt}"

    _is_audio_file() {
      file --mime-type "$1" | grep -qE 'audio/|video/'
    }

    _transcribe() {
      INPUT_FILE="''$1"

      if [ ! -f "''${INPUT_FILE}" ]; then
        >&2 echo "Skipping ''${INPUT_FILE}: file does not exist"
        return
      fi

      if ! _is_audio_file "''${INPUT_FILE}"; then
        >&2 echo "Skipping ''${INPUT_FILE}: not an audio file"
        return
      fi

      if [ -f "''${INPUT_FILE%.*}.''${FORMAT}" ]; then
        >&2 echo "Skipping ''${INPUT_FILE}: transcription already exists"
        return
      fi

      >&2 echo "Processing ''${INPUT_FILE}:"
      >&2 echo "+ language: ''${LANGUAGE}"
      >&2 echo "+ model: ''${MODEL}"
      >&2 echo "+ format: ''${FORMAT}"

      ${pkgs.openai-whisper}/bin/whisper "''${INPUT_FILE}" --language "''${LANGUAGE}" --model "''${MODEL}" --output_format "''${FORMAT}" 2>/dev/null
    }

    if [ $# -ne 1 ]; then
      for file in *; do
        _transcribe "$file"
      done
    else
      _transcribe "''${1}"
    fi
  '';
in
{
  config.home.packages = [
    audio
    image
    psalmus
    speak
    transcribe
    video
  ];
}
