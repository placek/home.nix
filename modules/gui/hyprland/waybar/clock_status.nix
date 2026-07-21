{ pkgs
, config
, ...
}:
let
  gcalcli = "${pkgs.gcalcli}/bin/gcalcli";
  today_color = config.gui.theme.base0F;
  header_color = config.gui.theme.base03;
  next_color = config.gui.theme.base0F;
  now_color = config.gui.theme.base09;
in
pkgs.writeScriptBin "clock_status" ''
  #!${pkgs.python3}/bin/python3
  import calendar as _cal
  import datetime as dt
  import json
  import os
  import pathlib
  import subprocess
  import sys

  TODAY_COLOR = "${today_color}"
  HEADER_COLOR = "${header_color}"
  NEXT_COLOR = "${next_color}"
  NOW_COLOR = "${now_color}"
  GCALCLI = "${gcalcli}"
  CACHE_TTL = 300           # seconds; reuse cached agenda within this window
  RANGE_DAYS = 7            # how many days of agenda to show
  MAX_LINES = 24           # cap tooltip agenda lines

  def esc(s):
      return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

  def build_month(now):
      y, m, d = now.year, now.month, now.day
      cal = _cal.Calendar(firstweekday=0)  # Monday
      weeks = cal.monthdayscalendar(y, m)
      hdr = "Mo Tu We Th Fr Sa Su   Wk"
      lines = [now.strftime("%B %Y").center(len(hdr)),
               f"<span color=\"{HEADER_COLOR}\">{hdr}</span>"]
      for wk in weeks:
          cells = []
          for day in wk:
              if day == 0:
                  cells.append("  ")
              elif day == d:
                  cells.append(f"<span color=\"{TODAY_COLOR}\">{day:2}</span>")
              else:
                  cells.append(f"{day:2}")
          anchor = next((x for x in wk if x != 0), 1)
          wn = dt.date(y, m, anchor).isocalendar()[1]
          lines.append(" ".join(cells) + f"   {wn:2}")
      return "\n".join(lines)

  def authorized():
      candidates = [
          pathlib.Path.home() / ".local/share/gcalcli/oauth",
          pathlib.Path.home() / ".gcalcli_oauth",
      ]
      return any(p.exists() for p in candidates)

  def fetch_tsv(start, end):
      # Return raw gcalcli tsv, using a short-lived cache to avoid hammering the
      # API on every bar refresh. Falls back to a stale cache on failure.
      rt = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
      cache = pathlib.Path(rt) / "waybar-agenda.tsv"
      try:
          age = dt.datetime.now().timestamp() - cache.stat().st_mtime
          if age < CACHE_TTL:
              return cache.read_text()
      except OSError:
          pass
      try:
          out = subprocess.check_output(
              [GCALCLI, "--nocolor", "agenda", "--tsv", "--military",
               "--details", "calendar", start, end],
              stderr=subprocess.DEVNULL, timeout=15).decode()
          try:
              cache.write_text(out)
          except OSError:
              pass
          return out
      except Exception:
          try:
              return cache.read_text()   # stale beats nothing
          except OSError:
              return None

  def build_agenda(now):
      if not authorized():
          return "  agenda: run `gcalcli init`"
      start = now.strftime("%Y-%m-%d")
      end = (now + dt.timedelta(days=RANGE_DAYS)).strftime("%Y-%m-%d")
      raw = fetch_tsv(start, end)
      if not raw:
          return "  agenda: unavailable"
      rows = raw.splitlines()
      if len(rows) < 2:
          return "  no upcoming events"
      head = rows[0].split("\t")
      idx = {name: i for i, name in enumerate(head)}
      sd, st, ti = idx.get("start_date"), idx.get("start_time"), idx.get("title")
      ed, et = idx.get("end_date"), idx.get("end_time")

      def cell(col, i):
          return (col[i] if i is not None and i < len(col) else "").strip()

      def combine(day, time):
          try:
              d = dt.date.fromisoformat(day)
              return dt.datetime.combine(
                  d, dt.time.fromisoformat(time) if time else dt.time.min)
          except ValueError:
              return None

      # Parse into events with sortable start/end datetimes so we can flag the
      # event happening right now and the next upcoming one.
      events = []
      for row in rows[1:]:
          col = row.split("\t")
          if ti is None or ti >= len(col):
              continue
          day = cell(col, sd)
          time = cell(col, st)
          title = esc(cell(col, ti)) or "(no title)"
          events.append({
              "day": day, "time": time, "title": title,
              "start": combine(day, time),
              "end": combine(cell(col, ed), cell(col, et)),
          })

      # Timed events happening now (start <= now < end).
      now_idx = {i for i, e in enumerate(events)
                 if e["time"] and e["start"] and e["end"]
                 and e["start"] <= now < e["end"]}
      # Next upcoming timed event (soonest start >= now, not already ongoing).
      upcoming = [i for i, e in enumerate(events)
                  if e["time"] and e["start"] and e["start"] >= now
                  and i not in now_idx]
      next_i = min(upcoming, key=lambda i: events[i]["start"]) if upcoming else None

      lines, last_day = [], None
      for i, e in enumerate(events):
          if i >= MAX_LINES:
              lines.append("  …")
              break
          if e["day"] != last_day:
              last_day = e["day"]
              try:
                  label = dt.date.fromisoformat(e["day"]).strftime("%a %d %b")
              except ValueError:
                  label = e["day"]
              lines.append(f"<span color=\"{HEADER_COLOR}\">{label}</span>")
          when = e["time"] if e["time"] else "all-day"
          line = f"  {when:>5}  {e['title']}"
          if i in now_idx:
              line = f"<span color=\"{NOW_COLOR}\">{line}</span>"
          elif i == next_i:
              line = f"<span color=\"{NEXT_COLOR}\">{line}</span>"
          lines.append(line)
      return "\n".join(lines) if lines else "  no upcoming events"

  def main():
      now = dt.datetime.now()
      text = now.strftime("%F %R")
      tooltip = "<tt>" + build_month(now) + "\n\n" + build_agenda(now) + "</tt>"
      print(json.dumps({"text": f" {text} ", "tooltip": tooltip}))

  if __name__ == "__main__":
      main()
''
