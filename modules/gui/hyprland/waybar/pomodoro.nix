{ pkgs
, ...
}:
pkgs.writeScriptBin "pomodoro" ''
  #!${pkgs.python3}/bin/python3
  # Waybar pomodoro timer. Actions: status (default), toggle, reset, skip.
  # State persists in $XDG_RUNTIME_DIR so it survives bar refreshes.
  import json
  import os
  import pathlib
  import subprocess
  import sys
  import time

  NOTIFY = "${pkgs.libnotify}/bin/notify-send"
  WORK, BREAK, LONG, CYCLES = 25 * 60, 5 * 60, 15 * 60, 4
  CLOCK = chr(0xF017)      # nf-fa-clock_o
  COFFEE = chr(0xF0F4)     # nf-fa-coffee
  STATE = pathlib.Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "waybar-pomodoro.json"
  IDLE = {"phase": "idle", "running": False, "remaining": WORK, "end": 0, "cycles": 0}

  def load():
      try:
          return json.loads(STATE.read_text())
      except Exception:
          return dict(IDLE)

  def save(s):
      try:
          STATE.write_text(json.dumps(s))
      except OSError:
          pass

  def notify(msg):
      try:
          subprocess.Popen([NOTIFY, "-a", "pomodoro", "Pomodoro", msg])
      except Exception:
          pass

  def dur(phase):
      return {"work": WORK, "break": BREAK, "long": LONG}.get(phase, WORK)

  def start(s, phase):
      s["phase"] = phase
      s["running"] = True
      s["remaining"] = dur(phase)
      s["end"] = time.time() + dur(phase)

  def advance(s):
      if s["phase"] == "work":
          s["cycles"] = s.get("cycles", 0) + 1
          nxt = "long" if s["cycles"] % CYCLES == 0 else "break"
          notify("Work done, time for a break")
      else:
          nxt = "work"
          notify("Break over, back to work")
      start(s, nxt)

  def remaining(s):
      return int(round(s["end"] - time.time())) if s["running"] else int(s["remaining"])

  def main():
      action = sys.argv[1] if len(sys.argv) > 1 else "status"
      s = load()

      if action == "toggle":
          if s["phase"] == "idle":
              start(s, "work")
          elif s["running"]:
              s["remaining"], s["running"] = remaining(s), False
          else:
              s["running"], s["end"] = True, time.time() + s["remaining"]
          save(s)
      elif action == "reset":
          s = dict(IDLE)
          save(s)
      elif action == "skip":
          start(s, "work") if s["phase"] == "idle" else advance(s)
          save(s)

      if s["running"]:
          rem = remaining(s)
          while rem <= 0:
              advance(s)
              rem = remaining(s)
          save(s)
      else:
          rem = int(s["remaining"])

      phase = s["phase"]
      if phase == "idle":
          out = {"text": CLOCK, "class": "idle", "alt": "idle",
                 "tooltip": "Pomodoro: idle (click to start)"}
      else:
          icon = COFFEE if phase in ("break", "long") else CLOCK
          mm, ss = divmod(max(rem, 0), 60)
          label = {"work": "Work", "break": "Break", "long": "Long break"}.get(phase, phase)
          paused = "" if s["running"] else " (paused)"
          out = {"text": f"{icon} {mm:02d}:{ss:02d}", "class": phase, "alt": phase,
                 "tooltip": f"{label}{paused} - {mm:02d}:{ss:02d} left\nCycles: {s.get('cycles', 0)}"}
      print(json.dumps(out))

  if __name__ == "__main__":
      main()
''
