{ pkgs ? import <nixpkgs> {}
}:
{ settings
, colors
}:

let
  inherit (pkgs) stdenv lib fetchurl SDL autoPatchelfHook;
  inherit (lib) getLib;

  dfVersion = "0.47.05";
  url = "https://www.bay12games.com/dwarves/df_47_05_linux.tar.bz2";
  hash = "sha256-rHSm27fX2WIfQwQFCAMiq1DDX2YyNS/y6pI/bcWv/KM=";

  unfuck = (pkgs.callPackage (pkgs.path + "/pkgs/games/dwarf-fortress/unfuck.nix") {
    inherit dfVersion;
  }).overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });

  renderValue = v:
    if lib.isBool v then
      if v then "YES" else "NO"
    else if lib.isInt v then
      toString v
    else if lib.isPath v then
      builtins.baseNameOf (toString v)
    else if lib.isString v then
      v
    else
      throw "dwarf-fortress-raw: unsupported configuration value ${toString v}";

  renderOption = option: value:
    "[" + (lib.toUpper option) + ":" + (renderValue value) + "]";

  # Patch tokens in the stock file rather than replacing it, so every token
  # that isn't overridden keeps the default DF ships with.
  mkPatchCommands = file: dict:
    lib.concatStringsSep "\n"
      (lib.attrsets.mapAttrsToList (option: value: ''
        if grep -q '\[${lib.toUpper option}:' "${file}"; then
          sed -i 's|\[${lib.toUpper option}:[^]]*\]|${renderOption option value}|' "${file}"
        else
          echo "warning: no token ${lib.toUpper option} in ${file}" >&2
        fi
      '') dict);

  game = stdenv.mkDerivation {
    pname = "dwarf-fortress-raw";
    version = dfVersion;
    src = fetchurl { inherit url hash; };
    sourceRoot = ".";
    postUnpack = ''
      mv df_linux/* .
    '';

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ SDL (lib.getLib stdenv.cc.cc) unfuck ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r * $out
      find $out -type d -exec chmod 0755 {} \;
      find $out -type f -exec chmod 0644 {} \;
      chmod +x $out/libs/Dwarf_Fortress
      chmod +x $out/df
      [ -d $out/libs ] && rm -rf $out/libs/*.so $out/libs/*.so.* $out/libs/*.dylib
      rm -rf $out/df_linux
      cp $out/data/art/mouse.png mouse.png
      rm -rf $out/data/art/*
      mv mouse.png $out/data/art/mouse.png
      cp ${settings.font} $out/data/art/${builtins.baseNameOf (toString settings.font)}
      touch $out/data/art/mouse.png
      ${mkPatchCommands "$out/data/init/init.txt" settings}
      ${mkPatchCommands "$out/data/init/colors.txt" colors}
      runHook postInstall
    '';
  };
in
  pkgs.writeShellScriptBin "dwarves" ''
    dir="''${XDG_DATA_HOME:-$HOME/.local/share}/dwarves"
    mkdir -p "$dir"
    # Refresh the game files whenever the package changes; saves live in
    # data/save and are never part of the package, so they are left alone.
    if [ "$(cat "$dir/.store-path" 2>/dev/null)" != "${game}" ]; then
      chmod -R u+w "$dir"
      cp -RT --no-preserve=mode ${game} "$dir"
      chmod -R u+w "$dir"
      echo "${game}" > "$dir/.store-path"
    fi
    exec "$dir/df" "$@"
  ''
