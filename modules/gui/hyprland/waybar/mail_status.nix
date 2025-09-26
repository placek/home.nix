{ pkgs
, ...
}:
pkgs.writeScriptBin "mail_status" ''
  #!${pkgs.python3}/bin/python3
  import os, json, re, subprocess, sys

  def run_out(args):
      try:
          return subprocess.check_output(args, stderr=subprocess.DEVNULL).decode().strip()
      except (subprocess.CalledProcessError, FileNotFoundError):
          return None

  def nm_count(query):
      # --exclude=false counts even messages in excluded folders (if you use them)
      return run_out(["notmuch", "count", "--exclude=false", query])

  def auto_accounts_from_tags():
      tags_raw = run_out(["notmuch", "search", "--output=tags", "tag:unread"])
      if not tags_raw:
          return {}
      accounts = {}
      for line in tags_raw.splitlines():
          tag = line.strip()
          # Some notmuch versions just print the tag; be robust if it ever prints "tag:foo"
          tag = tag[4:] if tag.startswith("tag:") else tag
          m = re.match(r"account[:/](.+)$", tag)
          if m:
              name = m.group(1)
              accounts[name] = f'tag:"{tag}"'
      return accounts

  def load_account_queries():
      env = os.getenv("NOTMUCH_QUERIES")
      if env:
          try:
              obj = json.loads(env)
              # ensure values are strings
              return {str(k): str(v) for k, v in obj.items()}
          except Exception:
              pass
      # fallback to auto-detection from tags
      return auto_accounts_from_tags()

  total_s = nm_count("tag:unread")
  if not total_s:
      print(json.dumps({"text": ""}))
      return
  try:
      total = int(total_s)
  except ValueError:
      total = 0

  accounts = load_account_queries()
  per = {}
  for name, q in accounts.items():
      c = nm_count(f"tag:unread and ({q})")
      try:
          per[name] = int(c) if c is not None else 0
      except ValueError:
          per[name] = 0

  # build tooltip
  if per:
      # sort by count desc, then name
      lines = [f"{name}: {cnt}" for name, cnt in sorted(per.items(), key=lambda kv: (-kv[1], kv[0])) if cnt > 0]
      if not lines:
          lines = [f"{name}: 0" for name in sorted(per)]
      tooltip = "\n".join(lines)
  else:
      tooltip = f"Unread: {total}"

  if total == 0:
      print(json.dumps({"text": ""}))
      return
  text = f"{total}"
  print(json.dumps({"text": text, "tooltip": tooltip}))
''
