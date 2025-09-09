{ pkgs
, ...
}:
pkgs.writeScriptBin "player_status" ''
  #!${pkgs.python3}/bin/python3
  import subprocess, json

  def run(cmd):
      try:
          return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
      except subprocess.CalledProcessError:
          return None

  def main():
      status = run(["${pkgs.playerctl}/bin/playerctl", "status"])
      artist = run(["${pkgs.playerctl}/bin/playerctl", "metadata", "artist"])
      title  = run(["${pkgs.playerctl}/bin/playerctl", "metadata", "title"])
      if not status or status == "Stopped":
          print(json.dumps({"text": ""}))
          return

      icon = {
          "Playing": "",
          "Paused":  "",
          "Stopped": "",
      }.get(status, "")

      text = f"{icon} {artist} - {title}"
      print(json.dumps({"text": text}))

  if __name__ == "__main__":
      main()
''
