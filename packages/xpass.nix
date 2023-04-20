{ pkgs, ... }:
let
  settings = import ../settings;
  pass = "${pkgs.pass.withExtensions (exts: [ exts.pass-otp ])}/bin/pass";
  yq = "${pkgs.yq}/bin/yq";
  ydotool = "${pkgs.ydotool}/bin/ydotool";
in
pkgs.writeShellScriptBin "xpass" ''
  #!${pkgs.stdenv.shell}
  entry=$(find -L ${settings.key.store} -name "*.gpg" -type "f" -printf "%P\n" | sed 's/\.gpg$//' | xprompt -c -i)
  [[ -n $entry ]] || exit
  pass_output=$(${pass} "$entry" | sed '1s/^/password: /' | sed 's/^otpauth:/otp: &/')
  password=$(echo "$pass_output" | ${yq} -r ".password")
  user=$(echo "$pass_output" | ${yq} -r ".user")
  ${pass} otp --clip "$entry" 2> /dev/null
  ${ydotool} type "$user\t$password"
''
