{ pkgs
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

  def main():
      util = run([
          "nvidia-smi", "--query-gpu=utilization.gpu",
          "--format=csv,noheader,nounits"
      ])
      mem_used = run([
          "nvidia-smi", "--query-gpu=memory.used",
          "--format=csv,noheader,nounits"
      ])
      mem_total = run([
          "nvidia-smi", "--query-gpu=memory.total",
          "--format=csv,noheader,nounits"
      ])

      if not util:
          print(json.dumps({"text": "?"}))
          return

      text = f"{util}%"

      if mem_used and mem_total:
          text_alt = f"{mem_used}/{mem_total} MiB"
      else:
          text_alt = "?"

      print(json.dumps({ "text": text, "alt": text_alt }))

  if __name__ == "__main__":
      main()
''
