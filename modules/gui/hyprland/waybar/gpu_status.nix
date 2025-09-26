{ pkgs
, config
, ...
}:
pkgs.writeScriptBin "gpu_status" ''
  #!${pkgs.python3}/bin/python3
  import subprocess, json

  def run(cmd):
      try:
          return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
      except subprocess.CalledProcessError:
          return None
      except FileNotFoundError:
          return None

  def pick_icon(util_str):
      try:
          # take the first line in case of multiple GPUs
          u = int(util_str.splitlines()[0])
      except Exception:
          return ""
      if u < 33:
          color = "${config.gui.theme.base02}"
      elif u < 66:
          color = "${config.gui.theme.base03}"
      else:
          color = "${config.gui.theme.base01}"
      return f"<span color=\"{color}\"> </span>"

  def first_line(s):
      return s.splitlines()[0] if s else None

  def main():
      util_raw = run([
          "nvidia-smi", "--query-gpu=utilization.gpu",
          "--format=csv,noheader,nounits"
      ])
      mem_used_raw = run([
          "nvidia-smi", "--query-gpu=memory.used",
          "--format=csv,noheader,nounits"
      ])
      mem_total_raw = run([
          "nvidia-smi", "--query-gpu=memory.total",
          "--format=csv,noheader,nounits"
      ])

      if not util_raw:
          print(json.dumps({"text": "?"}))
          return

      util = first_line(util_raw)
      mem_used = first_line(mem_used_raw)
      mem_total = first_line(mem_total_raw)

      icon = pick_icon(util)
      text = f"{icon} {util}%"

      if mem_used and mem_total:
          text_alt = f"{icon} {mem_used}/{mem_total} MB"
      else:
          text_alt = f"{icon} ?"

      print(json.dumps({ "text": text, "alt": text_alt }))

  if __name__ == "__main__":
      main()
''
