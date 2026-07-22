{ pkgs
, ...
}:
pkgs.writeScriptBin "dunst_status" ''
  #!${pkgs.python3}/bin/python3
  import json
  import subprocess

  DUNSTCTL = "${pkgs.dunst}/bin/dunstctl"
  BELL = chr(0xF0F3)       # nf-fa-bell
  BELL_OFF = chr(0xF1F6)   # nf-fa-bell_slash

  def ctl(*args):
      try:
          return subprocess.check_output(
              [DUNSTCTL, *args], stderr=subprocess.DEVNULL, timeout=3).decode().strip()
      except Exception:
          return ""

  def main():
      paused = ctl("is-paused") == "true"
      try:
          n = int(ctl("count", "waiting") or "0")
      except ValueError:
          n = 0
      if paused:
          icon, cls = BELL_OFF, "paused"
          tip = f"Do not disturb: on ({n} waiting)" if n else "Do not disturb: on"
      else:
          icon, cls = BELL, "active"
          tip = f"{n} waiting" if n else "Do not disturb: off"
      text = f" {icon} {n} " if n else f" {icon} "
      print(json.dumps({"text": text, "class": cls, "tooltip": tip}))

  if __name__ == "__main__":
      main()
''
