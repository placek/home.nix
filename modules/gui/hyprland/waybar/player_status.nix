{ pkgs
, ...
}:
pkgs.writeScriptBin "player_status" ''
  #!${pkgs.python3}/bin/python3
  import subprocess, json

  PLAYERCTL = "${pkgs.playerctl}/bin/playerctl"

  def run(cmd):
      try:
          return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
      except subprocess.CalledProcessError:
          return None

  def pick_player():
      """
      Use --all-players to get statuses of all players and pick one.
      Prefer a Playing player, otherwise the first Paused player.
      Returns (player_name, status) or (None, None) if none active.
      """
      out = run([PLAYERCTL, "-a", "-f", "{{playerName}}: {{status}}", "status"])
      if not out:
          return (None, None)

      playing = []
      paused = []
      for line in out.splitlines():
          if ": " not in line:
              continue
          name, status = line.split(": ", 1)
          if status == "Playing":
              playing.append((name, status))
          elif status == "Paused":
              paused.append((name, status))
      if playing:
          return playing[0]
      if paused:
          return paused[0]
      return (None, None)

  def main():
      player, status = pick_player()

      if not player or not status:
          print(json.dumps({"text": ""}))
          return

      icon = {
          "Playing": "",
          "Paused":  "",
      }.get(status, "")

      # Query metadata for the chosen player
      artist = run([PLAYERCTL, "-p", player, "metadata", "artist"]) or ""
      title  = run([PLAYERCTL, "-p", player, "metadata", "title"]) or ""

      text = f"{icon}"
      tooltip = f"{artist} - {title}".strip(" -")
      print(json.dumps({"text": text, "tooltip": tooltip}))

  if __name__ == "__main__":
      main()
''
