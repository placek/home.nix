{ pkgs
}:
pkgs.writeShellScriptBin "psalmus" ''
  if [ $# -eq 0 ]; then
    data=$(date +"%Y-%m-%d")
  else
    data=$(date -d "$1" +"%Y-%m-%d" 2>/dev/null)
    if [ $? -ne 0 ]; then
      echo "Błąd: Nieprawidłowy format daty."
      exit 1
    fi
  fi

  numer_dnia=$(date -d "$data" +"%-j")
  numer_psalmu=$(( (numer_dnia * 79) % 150 + 1 ))

  echo "Data: $data"
  echo "Numer psalmu dla dnia $numer_dnia: $numer_psalmu"
''
